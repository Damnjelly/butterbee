import gleam/json.{type Json}
import gleam/list
import gleam/option.{type Option, None}

pub type CapabilityRequest {
  CapabilityRequest(
    accept_insecure_certs: Option(Bool),
    browser_name: Option(String),
    browser_version: Option(String),
    platform_name: Option(String),
    extensions: List(#(String, Json)),
    //TODO: proxy: Option(ProxyConfiguration),
  )
}

pub fn capability_request_to_json(capability_request: CapabilityRequest) -> Json {
  let CapabilityRequest(
    accept_insecure_certs:,
    browser_name:,
    browser_version:,
    platform_name:,
    extensions:,
  ) = capability_request
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
  )
}
