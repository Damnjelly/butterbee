////
////  ▗▄▄▖▗▞▀▚▖ ▄▄▄  ▄▄▄ ▄  ▄▄▄  ▄▄▄▄  
//// ▐▌   ▐▛▀▀▘▀▄▄  ▀▄▄  ▄ █   █ █   █ 
////  ▝▀▚▖▝▚▄▄▖▄▄▄▀ ▄▄▄▀ █ ▀▄▄▄▀ █   █ 
//// ▗▄▄▞▘               █             
////                                   
//// The session module contains commands and events for monitoring the status of the remote end.
//// 
//// https://w3c.github.io/webdriver-bidi/#module-session

import butterbee/internal/decoders
import butterbee/internal/socket
import gleam/dict.{type Dict}
import gleam/dynamic.{type Dynamic}
import gleam/dynamic/decode.{type Decoder}
import gleam/http
import gleam/http/request
import gleam/json.{type Json}
import gleam/list
import gleam/option.{type Option, None}
import youid/uuid.{type Uuid}

pub type CapabilitiesRequest {
  CapabilitiesRequest(
    accept_insecure_certs: Option(Bool),
    browser_name: Option(String),
    browser_version: Option(String),
    platform_name: Option(String),
    extensions: List(#(String, Json)),
    //TODO: proxy: Option(ProxyConfiguration),
  )
}

fn capabilities_request_to_json(
  capabilities_request: CapabilitiesRequest,
) -> Json {
  let CapabilitiesRequest(
    accept_insecure_certs:,
    browser_name:,
    browser_version:,
    platform_name:,
    extensions:,
  ) = capabilities_request

  // TODO: implement always match and first match options
  json.object([
    #(
      "capabilities",
      json.object([
        #(
          "alwaysMatch",
          json.object(
            [
              #("accept_insecure_certs", case accept_insecure_certs {
                None -> json.null()
                option.Some(value) -> json.bool(value)
              }),
              #("browser_name", case browser_name {
                None -> json.null()
                option.Some(value) -> json.string(value)
              }),
              #("browser_version", case browser_version {
                None -> json.null()
                option.Some(value) -> json.string(value)
              }),
              #("platform_name", case platform_name {
                None -> json.null()
                option.Some(value) -> json.string(value)
              }),
            ]
            |> list.append(extensions),
          ),
        ),
      ]),
    ),
  ])
}

pub type Capabilities {
  Capabilities(
    accept_insecure_certs: Bool,
    browser_name: String,
    browser_version: String,
    platform_name: String,
    //WARN: not implemented in firefox
    //set_window_rect: Bool,
    user_agent: String,
    //TODO: proxy: Option(ProxyConfiguration),
    //TODO: unhandled_prompt_behavior: Option(UnhandledPromptBehavior),
    web_socket_url: Option(String),
    extensions: Dict(String, Dynamic),
  )
}

fn capabilities_decoder() -> Decoder(Capabilities) {
  use accept_insecure_certs <- decode.field("acceptInsecureCerts", decode.bool)
  use browser_name <- decode.field("browserName", decode.string)
  use browser_version <- decode.field("browserVersion", decode.string)
  use platform_name <- decode.field("platformName", decode.string)
  use user_agent <- decode.field("userAgent", decode.string)
  use web_socket_url <- decode.optional_field(
    "webSocketUrl",
    None,
    decode.optional(decode.string),
  )
  decode.success(Capabilities(
    accept_insecure_certs,
    browser_name,
    browser_version,
    platform_name,
    user_agent,
    web_socket_url,
    dict.new(),
  ))
}

fn extensions_decoder() -> Decoder(Dict(String, Dynamic)) {
  use capabilities <- decode.then(decode.dict(decode.string, decode.dynamic))

  let extensions =
    capabilities
    |> dict.to_list()
    |> list.filter(fn(entry) {
      let #(key, _value) = entry
      // Keep only non-standard capabilities
      case key {
        "acceptInsecureCerts"
        | "browserName"
        | "browserVersion"
        | "platformName"
        | "setWindowRect"
        | "userAgent"
        | "webSocketUrl"
        | "proxy" -> False
        _ -> True
      }
    })
    |> dict.from_list()

  decode.success(extensions)
}

pub type Session {
  Session(session_id: Uuid, capabilities: Capabilities)
}

fn session_decoder() -> Decoder(Session) {
  use session_id <- decode.field("sessionId", decoders.uuid())
  use generic <- decode.field("capabilities", capabilities_decoder())
  use extensions <- decode.field("capabilities", extensions_decoder())
  decode.success(Session(
    session_id,
    Capabilities(
      generic.accept_insecure_certs,
      generic.browser_name,
      generic.browser_version,
      generic.platform_name,
      generic.user_agent,
      generic.web_socket_url,
      extensions,
    ),
  ))
}

pub type Methods {
  New
}

fn method_to_string(command: Methods) -> String {
  case command {
    New -> "session.new"
  }
}

/// Creates a new BiDi session with the given capabilities.
pub fn new(
  capabilities: CapabilitiesRequest,
) -> #(socket.WebDriverSocket, Session) {
  // TODO: get from toml
  let url =
    request.new()
    |> request.set_host("127.0.0.1")
    |> request.set_port(9222)
    |> request.set_path("/session")
    |> request.set_scheme(http.Http)

  let socket = socket.new(url)
  let request =
    socket.bidi_request(
      method_to_string(New),
      capabilities_request_to_json(capabilities),
    )

  let assert Ok(session) =
    socket.send_request(socket, request)
    |> decode.run(session_decoder())

  #(socket, session)
}
