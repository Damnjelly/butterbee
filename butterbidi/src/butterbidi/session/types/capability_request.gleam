import butterbidi/extensible
import gleam/dict.{type Dict}
import gleam/dynamic.{type Dynamic}
import gleam/dynamic/decode
import gleam/json.{type Json}
import gleam/list
import gleam/option.{type Option, None}

pub type CapabilityRequest {
  CapabilityRequest(
    accept_insecure_certs: Option(Bool),
    browser_name: Option(String),
    browser_version: Option(String),
    platform_name: Option(String),
    extensible: Dict(String, Dynamic),
    //TODO: proxy: Option(ProxyConfiguration),
  )
}

pub fn default() -> CapabilityRequest {
  CapabilityRequest(None, None, None, None, dict.new())
}

pub fn capability_request_decoder() -> decode.Decoder(CapabilityRequest) {
  use accept_insecure_certs <- decode.optional_field(
    "acceptInsecureCerts",
    None,
    decode.optional(decode.bool),
  )
  use browser_name <- decode.optional_field(
    "browserName",
    None,
    decode.optional(decode.string),
  )
  use browser_version <- decode.optional_field(
    "browserVersion",
    None,
    decode.optional(decode.string),
  )
  use platform_name <- decode.optional_field(
    "platformName",
    None,
    decode.optional(decode.string),
  )
  use extensible <- decode.then(decode.dict(decode.string, decode.dynamic))
  decode.success(CapabilityRequest(
    accept_insecure_certs:,
    browser_name:,
    browser_version:,
    platform_name:,
    extensible:,
  ))
}

pub fn capability_request_to_json(capability_request: CapabilityRequest) -> Json {
  let CapabilityRequest(
    accept_insecure_certs:,
    browser_name:,
    browser_version:,
    platform_name:,
    extensible:,
  ) = capability_request
  let options =
    list.new()
    |> list.append(case accept_insecure_certs {
      None -> []
      option.Some(value) -> [#("acceptInsecureCerts", json.bool(value))]
    })
    |> list.append(case browser_name {
      None -> []
      option.Some(value) -> [#("browserName", json.string(value))]
    })
    |> list.append(case browser_version {
      None -> []
      option.Some(value) -> [#("browserVersion", json.string(value))]
    })
    |> list.append(case platform_name {
      None -> []
      option.Some(value) -> [#("platformName", json.string(value))]
    })
    |> list.append(extensible.extensible_to_list(extensible))

  json.object(options)
}
