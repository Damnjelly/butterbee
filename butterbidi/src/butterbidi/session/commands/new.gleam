import butterbidi/session/types/capabilities_request.{type CapabilitiesRequest}
import gleam/dict.{type Dict}
import gleam/dynamic.{type Dynamic}
import gleam/dynamic/decode.{type Decoder}
import gleam/list
import internal/decoders
import youid/uuid.{type Uuid}

pub type NewParameters {
  NewParameters(CapabilitiesRequest)
}

pub type NewResult {
  NewResult(session_id: Uuid, capabilities: Capabilities)
}

pub fn new_result_decoder() -> Decoder(NewResult) {
  use session_id <- decode.field("sessionId", decoders.uuid())
  use capabilities <- decode.field("capabilities", capabilities_decoder())
  use extensible <- decode.field(
    "capabilities",
    extensible_capabilities_decoder(),
  )
  decode.success(NewResult(
    session_id:,
    capabilities: Capabilities(
      capabilities.accept_insecure_certs,
      capabilities.browser_name,
      capabilities.browser_version,
      capabilities.platform_name,
      capabilities.user_agent,
      extensible,
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
    extensible: Dict(String, Dynamic),
  )
}

fn capabilities_decoder() -> Decoder(Capabilities) {
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

pub fn extensible_capabilities_decoder() -> Decoder(Dict(String, Dynamic)) {
  use capabilities <- decode.then(decode.dict(decode.string, decode.dynamic))

  let extensible =
    dict.to_list(capabilities)
    |> list.filter(fn(entry) {
      let #(key, _value) = entry
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

  decode.success(extensible)
}
