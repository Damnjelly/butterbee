//// The socket module contains the websocket connection to the webdriver server

import butterbee/internal/glam
import butterbee/internal/retry
import butterbidi/definition
import butterlib/log
import gleam/dict
import gleam/dynamic/decode.{type Decoder}
import gleam/erlang/process
import gleam/http/request.{type Request}
import gleam/json.{type Json}
import gleam/otp/actor
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

// TODO: Less asserts
pub fn new(request: Request(String)) -> WebDriverSocket {
  log.debug(
    "Connecting to WebDriver server at "
    <> request.to_uri(request) |> uri.to_string(),
  )
  let state = dict.new()

  let subject =
    stratus.new(request, state)
    |> stratus.on_message(fn(state, msg, conn) {
      case msg {
        stratus.Text(msg) -> {
          log_response(msg)
          let assert Ok(result) = json.parse(msg, definition.message_decoder())
            as "Failed to parse webdriver response"
          case result {
            definition.Success -> {
              let assert Ok(id) = json.parse(msg, id_decoder())
              let assert Ok(subject) = dict.get(state, id)
                as "Failed to find corresponding response"
              process.send(subject, Ok(msg))
              stratus.continue(state |> dict.drop([id]))
            }
            definition.Error -> {
              let assert Ok(id) = json.parse(msg, id_decoder())
              let assert Ok(subject) = dict.get(state, id)
                as "Failed to find corresponding response"
              process.send(subject, Error(msg))
              stratus.continue(state |> dict.drop([id]))
            }
          }
        }
        stratus.Binary(_) -> stratus.continue(state)
        stratus.User(SendCommand(subject, request)) -> {
          let id_d = {
            use id <- decode.field("id", decode.int)
            decode.success(id)
          }
          let assert Ok(id) = json.parse(request, id_d)
          log_request(request)
          let assert Ok(_) = stratus.send_text_message(conn, request)
            as "Failed to send webdriver request"
          stratus.continue(dict.insert(state, id, subject))
        }
        stratus.User(Close) -> {
          let assert Ok(_) = stratus.close(conn)
          stratus.stop()
        }
      }
    })

  let assert Ok(subject) =
    retry.until_ok(fn() { stratus.start(subject) }, fn(result) {
      case result {
        Ok(_) -> Ok(subject)
        Error(_) -> Error("Failed to connect to webdriver server")
      }
    })
    as "Failed to connect to webdriver server"

  WebDriverSocket(subject)
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
) -> Result(definition.CommandResponse, definition.ErrorResponse) {
  let result =
    process.call(socket.actor.data, request_timeout, fn(subject) {
      stratus.to_user_message(SendCommand(subject, json.to_string(request)))
    })

  case result {
    Ok(result) -> {
      let assert Ok(result) =
        json.parse(result, definition.command_response_decoder(command))

      Ok(result)
    }
    Error(error) -> {
      let assert Ok(error) =
        json.parse(error, definition.error_response_decoder())

      Error(error)
    }
  }
}

fn log_response(response: String) {
  log.debug("------------------- Received WebDriver Response -------------------
    " <> glam.pretty_json(response))
}

fn log_request(request: String) {
  log.debug("------------------- Sending WebDriver Request -------------------
    " <> glam.pretty_json(request))
}
