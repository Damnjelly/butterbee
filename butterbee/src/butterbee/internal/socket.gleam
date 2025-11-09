//// The socket module contains the websocket connection to the webdriver server

import butterbee/internal/error
import butterbee/internal/glam
import butterbee/internal/retry
import butterbidi/definition
import gleam/dict
import gleam/dynamic/decode.{type Decoder}
import gleam/http/request.{type Request}
import gleam/json.{type Json}
import gleam/result
import gleam/uri
import palabres as log

@target(erlang)
import gleam/erlang/process
@target(erlang)
import gleam/otp/actor
@target(erlang)
import stratus as websocket

@target(javascript)
import gleam/javascript/promise
@target(javascript)
import stratocumulus.{type WebSocket} as websocket

const request_timeout = 5000

fn log_response(response: String) {
  log.debug("")
  |> log.string("response", "\n" <> glam.pretty_json(response))
  |> log.log
}

fn log_request(request: String) {
  log.debug("")
  |> log.string("request", "\n" <> glam.pretty_json(request))
  |> log.log
}

fn id_decoder() -> Decoder(Int) {
  use id <- decode.field("id", decode.int)
  decode.success(id)
}

// ─────────────────────────────────────────────────────────────────────────
// ERLANG WEBSOCKET
// ─────────────────────────────────────────────────────────────────────────

@target(erlang)
pub type WebDriverSocket {
  WebDriverSocket(
    actor: actor.Started(process.Subject(websocket.InternalMessage(Msg))),
  )
}

@target(erlang)
pub type Msg {
  SendCommand(subject: process.Subject(Result(String, String)), request: String)
  Close
}

@target(erlang)
pub fn new(
  request: Request(String),
) -> Result(WebDriverSocket, error.ButterbeeError) {
  log.debug("Connecting to WebDriver server")
  |> log.string("url", request.to_uri(request) |> uri.to_string())
  |> log.log

  let state = Ok(dict.new())

  let subject =
    websocket.new(request, state)
    |> websocket.on_message(fn(state, msg, conn) {
      case msg {
        websocket.Text(msg) -> {
          log_response(msg)

          let state = case state {
            Error(error) -> Error(error)
            Ok(state) -> {
              use id <- result.try({
                json.parse(msg, id_decoder())
                |> result.map_error(error.CouldNotGetIdFromSocketResponse)
              })

              use subject <- result.try({
                dict.get(state, id)
                |> result.map_error(fn(_) {
                  error.ResponseDoesNotHaveCorrespondingRequestId(id)
                })
              })

              use result <- result.try({
                json.parse(msg, definition.message_decoder())
                |> result.map_error(error.CouldNotParseSocketResponse)
              })

              let msg = case result {
                definition.Success -> Ok(msg)
                definition.Error -> Error(msg)
              }

              process.send(subject, msg)
              Ok(state |> dict.drop([id]))
            }
          }
          websocket.continue(state)
        }
        websocket.Binary(_) -> websocket.continue(state)
        websocket.User(SendCommand(subject, request)) -> {
          let id_decoder = {
            use id <- decode.field("id", decode.int)
            decode.success(id)
          }

          let state = case state {
            Error(error) -> Error(error)
            Ok(state) -> {
              use id <- result.try({
                json.parse(request, id_decoder)
                |> result.map_error(error.CouldNotGetIdFromSendCommand)
              })

              log_request(request)

              use _ <- result.try({
                case websocket.send_text_message(conn, request) {
                  Ok(_) -> Ok(Nil)
                  Error(err) ->
                    Error(error.WebSocketError(error.CouldNotSendRequest(err)))
                }
              })

              Ok(dict.insert(state, id, subject))
            }
          }
          websocket.continue(state)
        }
        websocket.User(Close) -> {
          let _ = websocket.close(conn, websocket.NotProvided)
          websocket.stop()
        }
      }
    })

  use subject <- result.try({
    case retry.until_ok(fn() { websocket.start(subject) }) {
      Ok(subject) -> Ok(subject)
      Error(err) -> Error(error.WebSocketError(error.CouldNotInit(err)))
    }
  })

  Ok(WebDriverSocket(subject))
}

@target(erlang)
/// Close the websocket connection
pub fn close(socket: WebDriverSocket) {
  websocket.to_user_message(Close)
  |> process.send(socket.actor.data, _)
}

@target(erlang)
/// Send a request to the webdriver server
/// Returns the result from the server as a dynamic
pub fn send_request(
  socket: WebDriverSocket,
  request: Json,
  command: definition.CommandData,
) -> Result(definition.CommandResponse, error.ButterbeeError) {
  let result =
    process.call(socket.actor.data, request_timeout, fn(subject) {
      websocket.to_user_message(SendCommand(subject, json.to_string(request)))
    })

  case result {
    Ok(result) -> {
      use result <- result.try({
        json.parse(result, definition.command_response_decoder(command))
        |> result.map_error(error.CouldNotParseResponse)
      })

      Ok(result)
    }
    Error(error) -> {
      use error <- result.try({
        json.parse(error, definition.error_response_decoder())
        |> result.map_error(error.CouldNotParseResponse)
      })

      Error(error.BidiError(error))
    }
  }
}
