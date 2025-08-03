import butterbee/bidi/method.{End, New}
import butterbee/bidi/session/types/capabilities_request.{
  type CapabilitiesRequest, capabilities_request_to_json,
}
import butterbee/internal/decoders
import butterbee/internal/socket
import gleam/dict.{type Dict}
import gleam/dynamic.{type Dynamic}
import gleam/dynamic/decode.{type Decoder}
import gleam/http
import gleam/http/request
import gleam/json
import gleam/list
import youid/uuid

///
/// # [session.new](https://w3c.github.io/webdriver-bidi/#command-session-new)
///
/// Creates a new BiDi session with the given capabilities.
///
/// ## Example
///
/// ```gleam
/// let session =
///   session.new(CapabilitiesRequest(
///     Some(CapabilityRequest(None, None, None, None, [])),
///     None,
///   ))
/// ```
///
pub fn new(
  capabilities_request: CapabilitiesRequest,
) -> #(socket.WebDriverSocket, NewResult) {
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
      method.to_string(New),
      capabilities_request_to_json(capabilities_request),
    )

  let assert Ok(result) =
    socket.send_request(socket, request)
    |> decode.run(new_result_decoder())

  #(socket, result)
}

pub type NewParameters {
  NewParameters(CapabilitiesRequest)
}

pub type NewResult {
  NewResult(session_id: uuid.Uuid, capabilities: Capabilities)
}

fn new_result_decoder() -> Decoder(NewResult) {
  use session_id <- decode.field("sessionId", decoders.uuid())
  use capabilities <- decode.field("capabilities", capabilities_decoder())
  use extensions <- decode.field("capabilities", extensions_decoder())
  decode.success(NewResult(
    session_id:,
    capabilities: Capabilities(
      capabilities.accept_insecure_certs,
      capabilities.browser_name,
      capabilities.browser_version,
      capabilities.platform_name,
      capabilities.user_agent,
      extensions,
    ),
  ))
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
    extensions: Dict(String, Dynamic),
  )
}

pub fn capabilities_decoder() -> Decoder(Capabilities) {
  use accept_insecure_certs <- decode.field("acceptInsecureCerts", decode.bool)
  use browser_name <- decode.field("browserName", decode.string)
  use browser_version <- decode.field("browserVersion", decode.string)
  use platform_name <- decode.field("platformName", decode.string)
  use user_agent <- decode.field("userAgent", decode.string)
  decode.success(Capabilities(
    accept_insecure_certs,
    browser_name,
    browser_version,
    platform_name,
    user_agent,
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

pub fn end(socket: socket.WebDriverSocket) -> Nil {
  let request = socket.bidi_request(method.to_string(End), json.object([]))

  socket.send_request(socket, request)

  Nil
}
