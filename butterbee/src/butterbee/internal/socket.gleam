//// The socket module contains the websocket connection to the webdriver server

import butterbee/internal/error
import butterbee/internal/glam
import butterbee/internal/retry
import butterbidi/definition
import gleam/dict
import gleam/dynamic/decode.{type Decoder}
import gleam/erlang/process
import gleam/http/request.{type Request}
import gleam/json.{type Json}
import gleam/otp/actor
import gleam/result
import gleam/string
import gleam/uri
import palabres as logger
import stratus as websocket

const request_timeout = 5000

fn logger_response(response: String) {
  logger.debug("")
  |> logger.string("response", "\n" <> glam.pretty_json(response))
  |> logger.log
}

fn logger_request(request: String) {
  logger.debug("")
  |> logger.string("request", "\n" <> glam.pretty_json(request))
  |> logger.log
}

fn id_decoder() -> Decoder(Int) {
  use id <- decode.field("id", decode.int)
  decode.success(id)
}

pub type WebDriverSocket {
  WebDriverSocket(
    actor: actor.Started(process.Subject(websocket.InternalMessage(Msg))),
  )
}

pub type Msg {
  SendCommand(subject: process.Subject(Result(String, String)), request: String)
  Close
}

pub fn new(
  request: Request(String),
) -> Result(WebDriverSocket, error.ButterbeeError) {
  logger.debug("Connecting to WebDriver server")
  |> logger.string("url", request.to_uri(request) |> uri.to_string())
  |> logger.log

  let state = Ok(dict.new())

  let subject =
    websocket.new(request, state)
    |> websocket.on_message(fn(state, msg, conn) {
      case msg {
        websocket.Text(msg) -> {
          logger_response(msg)

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

              logger_request(request)

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

/// Close the websocket connection
pub fn close(socket: WebDriverSocket) {
  websocket.to_user_message(Close)
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
      websocket.to_user_message(SendCommand(subject, json.to_string(request)))
    })

  case result {
    Ok(result) -> {
      case json.parse(result, definition.command_response_decoder(command)) {
        Ok(result) -> Ok(result)
        Error(error) -> {
          logger.error("Could not parse success response")
          |> logger.string("response", result)
          |> logger.string("error", string.inspect(error))
          |> logger.log

          Error(error.CouldNotParseResponse(error))
        }
      }
    }
    Error(result) -> {
      case json.parse(result, definition.error_response_decoder()) {
        Ok(result) -> Error(error.BidiError(result))
        Error(error) -> {
          logger.error("Could not parse error response")
          |> logger.string("response", result)
          |> logger.string("error", string.inspect(error))
          |> logger.log

          Error(error.CouldNotParseResponse(error))
        }
      }
    }
  }
}
