import gleam/dict.{type Dict}
import gleam/dynamic/decode
import gleam/list
import gleam/result
import logging
import tom

pub const default_host = "127.0.0.1"

pub const default_port_range = #(9222, 9232)

pub const default_port = 9222

pub type BrowserType {
  Firefox
  Chrome
}

pub fn browser_type_decoder() -> decode.Decoder(BrowserType) {
  use browser_type <- decode.then(decode.string)
  case browser_type {
    "firefox" -> decode.success(Firefox)
    "chrome" -> decode.success(Chrome)
    _ -> decode.failure(Firefox, "Browser type not supported: " <> browser_type)
  }
}

pub fn default_browser_type() -> BrowserType {
  Firefox
}

pub fn default() -> Dict(BrowserType, BrowserConfig) {
  dict.new()
  |> dict.insert(Firefox, default_configuration())
}

pub fn browser_config_decoder() -> decode.Decoder(
  Dict(BrowserType, BrowserConfig),
) {
  use browser_config <- decode.then(decode.dict(
    browser_type_decoder(),
    configuration_options_decoder(),
  ))
  decode.success(browser_config)
}

pub type BrowserConfig {
  BrowserConfig(
    extra_flags: List(String),
    host: String,
    port_range: #(Int, Int),
  )
}

pub fn default_configuration() -> BrowserConfig {
  BrowserConfig(
    extra_flags: [],
    host: default_host,
    port_range: default_port_range,
  )
}

pub fn configuration_options_decoder() -> decode.Decoder(BrowserConfig) {
  use extra_flags <- decode.optional_field(
    "flags",
    [],
    decode.list(decode.string),
  )
  use host <- decode.optional_field("host", default_host, decode.string)
  use port_range <- decode.optional_field("port_range", default_port_range, {
    use a <- decode.field(0, decode.int)
    use b <- decode.field(1, decode.int)

    decode.success(#(a, b))
  })
  decode.success(BrowserConfig(extra_flags:, host:, port_range:))
}
