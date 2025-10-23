//// The socket module contains the websocket connection to the webdriver server

import butterbee/internal/error
import butterbee/internal/glam
import butterbee/internal/retry
import butterbidi/definition
import butterlib/log
import gleam/dict.{type Dict}
import gleam/dynamic/decode.{type Decoder}
import gleam/erlang/process
import gleam/http/request.{type Request}
import gleam/json.{type Json}
import gleam/otp/actor
import gleam/result
import gleam/uri
import stratus

const request_timeout = 5000

pub type Msg {
  SendCommand(subject: process.Subject(Result(String, String)), request: String)
  Close
}

pub type WebDriverSocket {
  WebDriverSocket(
    actor: actor.Started(process.Subject(stratus.InternalMessage(Msg))),
  )
}

pub fn new(
  request: Request(String),
) -> Result(WebDriverSocket, error.ButterbeeError) {
  log.debug(
    "Connecting to WebDriver server at "
    <> request.to_uri(request) |> uri.to_string(),
  )
  let state = Ok(dict.new())

  let subject =
    stratus.new(request, state)
    |> stratus.on_message(fn(state, msg, conn) {
      case msg {
        stratus.Text(msg) -> {
          log_response(msg)

          let state = case state {
            Error(error) -> Error(error)
            Ok(state) -> {
              use id <- result.try({
                json.parse(msg, id_decoder())
                |> result.map_error(error.CouldNotGetIdFromSocketResponse)
              })

              use subject <- result.try({
                get_subject(state, id)
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
          stratus.continue(state)
        }
        stratus.Binary(_) -> stratus.continue(state)
        stratus.User(SendCommand(subject, request)) -> {
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
                stratus.send_text_message(conn, request)
                |> result.map_error(error.CouldNotSendWebSocketRequest)
              })

              Ok(dict.insert(state, id, subject))
            }
          }
          stratus.continue(state)
        }
        stratus.User(Close) -> {
          let _ = stratus.close(conn)
          stratus.stop()
        }
      }
    })

  use subject <- result.try({
    retry.until_ok(fn() { stratus.start(subject) })
    |> result.map_error(error.CouldNotStartWebSocket)
  })

  Ok(WebDriverSocket(subject))
}

fn get_subject(
  state: Dict(Int, process.Subject(Result(String, String))),
  id: Int,
) -> Result(process.Subject(Result(String, String)), error.ButterbeeError) {
  use subject <- result.try({
    dict.get(state, id)
    |> result.map_error(fn(_) {
      error.ResponseDoesNotHaveCorrespondingRequestId(id)
    })
  })
  Ok(subject)
}

fn id_decoder() -> Decoder(Int) {
  use id <- decode.field("id", decode.int)
  decode.success(id)
}

/// Close the websocket connection
pub fn close(socket: WebDriverSocket) {
  stratus.to_user_message(Close)
  |> process.send(socket.actor.data, _)
}

/// Send a request to the webdriver server
/// Returns the result from the server as a dynamic
pub fn send_request(
  socket: WebDriverSocket,
  request: Json,
  command: definition.CommandData,
) -> Result(definition.CommandResponse, error.ButterbeeError) {
  let result =
    process.call(socket.actor.data, request_timeout, fn(subject) {
      stratus.to_user_message(SendCommand(subject, json.to_string(request)))
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

fn log_response(response: String) {
  log.debug("── Received WebDriver Response ───────────────────────
    " <> glam.pretty_json(response))
}

fn log_request(request: String) {
  log.debug("── Sending WebDriver Request ─────────────────────────
    " <> glam.pretty_json(request))
}
