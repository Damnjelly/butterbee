////
////  ▗▄▄▖ ▄▄▄  ▗▞▀▘█  ▄ ▗▞▀▚▖▗▄▄▄▖
//// ▐▌   █   █ ▝▚▄▖█▄▀  ▐▛▀▀▘  █  
////  ▝▀▚▖▀▄▄▄▀     █ ▀▄ ▝▚▄▄▖  █  
//// ▗▄▄▞▘          █  █        █  
////                                       
//// The socket module contains the websocket connection to the webdriver server

import birl
import butterbee/internal/decoders
import butterbee/internal/glam
import glam/doc
import gleam/dynamic
import gleam/dynamic/decode.{type Decoder}
import gleam/erlang/process
import gleam/http/request.{type Request}
import gleam/json.{type Json}
import gleam/option.{None}
import gleam/otp/actor
import gleam/uri
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

pub type WebDriverSocket {
  WebDriverSocket(
    actor: actor.Started(process.Subject(stratus.InternalMessage(Msg))),
  )
}

pub fn new(request: Request(String)) -> WebDriverSocket {
  // TODO: change state to a Dict(id: Int, subject: process.Subject(String))
  logging.log(
    logging.Debug,
    "Connecting to WebDriver server at "
      <> request.to_uri(request) |> uri.to_string(),
  )
  let state = process.new_subject()
  let builder =
    stratus.websocket(
      request: request,
      init: fn() { #(state, None) },
      loop: fn(state, msg, conn) {
        case msg {
          stratus.Text(msg) -> {
            // TODO: match msg.id with the id in the state

            logging.log(
              logging.Debug,
              "------------------- Received WebDriver Response -------------------
"
                <> glam.pretty_json(msg),
            )

            let assert Ok(result) = json.parse(msg, success_result_decoder())
              as "Failed to parse webdriver response"

            case result.result_type {
              Success -> {
                process.send(state, msg)
                stratus.continue(state)
              }
              Error -> {
                let assert Ok(result) = json.parse(msg, decode.dynamic)
                  as "Failed to parse webdriver error response"

                let assert Ok(result) =
                  decode.run(result, error_result_decoder())

                let error_msg = result.error <> ", " <> result.message
                panic as error_msg
              }
            }
          }
          stratus.Binary(_) -> stratus.continue(state)
          stratus.User(SendCommand(subject, request)) -> {
            logging.log(
              logging.Debug,
              "------------------- Sending WebDriver Request -------------------
" <> glam.pretty_json(request),
            )
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
    #("id", json.int(birl.utc_now() |> birl.to_unix_micro())),
    #("method", json.string(method)),
    #("params", params),
  ])
}

type SuccessResult {
  SuccessResult(result_type: ResultType, result: dynamic.Dynamic, id: Int)
}

fn success_result_decoder() -> Decoder(SuccessResult) {
  use result_type <- decode.field("type", decode.string)
  use result <- decode.field("result", decode.dynamic)
  use id <- decode.field("id", decode.int)

  let result_type = case result_type {
    "success" -> Success
    "error" -> Error
    _ -> panic as "Unknown webdriver response type"
  }

  decode.success(SuccessResult(result_type:, result:, id:))
}

type ErrorResult {
  ErrorResult(error: String, message: String, stacktrace: String)
}

fn error_result_decoder() -> Decoder(ErrorResult) {
  use error <- decode.field("error", decode.string)
  use message <- decode.field("message", decode.string)
  use stacktrace <- decode.field("stacktrace", decode.string)
  decode.success(ErrorResult(error:, message:, stacktrace:))
}
