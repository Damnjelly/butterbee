////
////  ▗▄▄▖ ▄▄▄  ▗▞▀▘█  ▄ ▗▞▀▚▖▗▄▄▄▖
//// ▐▌   █   █ ▝▚▄▖█▄▀  ▐▛▀▀▘  █  
////  ▝▀▚▖▀▄▄▄▀     █ ▀▄ ▝▚▄▄▖  █  
//// ▗▄▄▞▘          █  █        █  
////                                       
//// The socket module contains the websocket connection to the webdriver server

import butterbee/internal/decoders
import butterbee/internal/helper
import gleam/dynamic
import gleam/dynamic/decode.{type Decoder}
import gleam/erlang/process
import gleam/http/request.{type Request}
import gleam/json.{type Json}
import gleam/option.{None}
import gleam/otp/actor
import gleam_community/ansi
import logging
import stratus

const request_timeout = 1000

pub type Msg {
  SendCommand(subject: process.Subject(String), request: String)
  Close
}

pub type ResultType {
  Success
  Error
}

pub type GenericResult {
  GenericResult(result_type: ResultType, result: String)
}

pub type WebDriverSocket {
  WebDriverSocket(
    actor: actor.Started(process.Subject(stratus.InternalMessage(Msg))),
  )
}

pub fn new(request: Request(String)) -> WebDriverSocket {
  // TODO: change state to a Dict(id: Int, subject: process.Subject(String))
  let state = process.new_subject()
  let builder =
    stratus.websocket(
      request: request,
      init: fn() { #(state, None) },
      loop: fn(state, msg, conn) {
        case msg {
          stratus.Text(msg) -> {
            // TODO: match msg.id with the id in the state
            let assert Ok(result) = json.parse(msg, bidi_result())
              as "Failed to parse webdriver response"

            logging.log(logging.Info, {
              "-------------------- Response --------------------"
            })
            helper.echo_json(msg)
            logging.log(logging.Info, {
              "-------------------- Response --------------------"
            })
            case result {
              Success -> {
                process.send(state, msg)
                stratus.continue(state)
              }
              Error -> {
                let assert Ok(error) = json.parse(msg, bidi_error())
                panic as error
              }
            }
          }
          stratus.Binary(_) -> stratus.continue(state)
          stratus.User(SendCommand(subject, request)) -> {
            logging.log(logging.Info, {
              "-------------------- Request --------------------"
            })
            helper.echo_json(request)
            logging.log(logging.Info, {
              "-------------------- Request --------------------"
            })
            let assert Ok(_) = stratus.send_text_message(conn, request)
              as "Failed to send webdriver request"
            stratus.continue(subject)
          }
          stratus.User(Close) -> {
            let assert Ok(_) = stratus.close(conn)
            stratus.stop()
          }
        }
      },
    )
    |> stratus.on_close(fn(state) {
      echo state
      Nil
    })

  let assert Ok(subject) = stratus.initialize(builder)
    as "Failed to initialize websocket connection"

  WebDriverSocket(subject)
}

/// Close the websocket connection
pub fn close(socket: WebDriverSocket) {
  stratus.to_user_message(Close)
  |> process.send(socket.actor.data, _)
}

/// Send a request to the webdriver server
/// Returns the result from the server as a dynamic
pub fn send_request(socket: WebDriverSocket, request: Json) -> dynamic.Dynamic {
  let assert Ok(result) =
    process.call(socket.actor.data, request_timeout, fn(subject) {
      stratus.to_user_message(SendCommand(subject, json.to_string(request)))
    })
    |> json.parse(decoders.result())

  result
}

pub fn bidi_request(method: String, params: Json) -> Json {
  // TODO: change id to a randomized Int
  json.object([
    #("id", json.int(1)),
    #("method", json.string(method)),
    #("params", params),
  ])
}

fn bidi_result() -> Decoder(ResultType) {
  decode.field("type", decode.string, fn(type_str) {
    case type_str {
      "success" -> Success
      "error" -> Error
      _ -> panic as "Unknown webdriver response type"
    }
    |> decode.success
  })
}

fn bidi_error() -> Decoder(String) {
  use error <- decode.field("error", decode.string)
  use message <- decode.field("message", decode.string)
  use stacktrace <- decode.field("stacktrace", decode.string)
  decode.success(
    ansi.red(
      "
Webdriver error: ",
    )
    <> error
    <> ansi.red(
      "
Message: ",
    )
    <> message
    <> ansi.red(
      "
Stacktrace: ",
    )
    <> stacktrace,
  )
}
