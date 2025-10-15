////
//// # Browser Config Module
////
//// This module provides functionality for parsing and creating browser configurations
//// from TOML configuration files for WebDriver BiDi sessions.
////
//// ## Overview
////
//// Butterbee uses WebDriver BiDi to communicate with browsers, and the browser 
//// configuration specifies the desired browser and its configuration options.
////
//// ## TOML Configuration Format
////
//// The browser configuration is defined in a TOML configuration file under the
//// `[Browsers]` section:
////
//// ```toml
//// [Browsers]
////
//// [Browsers.firefox]
////
//// cmd = "firefox"
//// flags = ["-headless"]
//// host = "127.0.0.1"
//// port_range = [9222, 9282]
////
//// # NOTE: chromium is not supported yet
//// [Browsers.chromium]
//// cmd = "chromium"
//// flags = []
//// host = "127.0.0.1"
//// port_range = [9143, 9163]
//// ```
////

import gleam/dict.{type Dict}
import gleam/dynamic/decode

/// Butterbee will use this command unless overridden
pub const default_cmd = "firefox"

/// Butterbee will use this host url unless overridden 
pub const default_host = "127.0.0.1"

/// Butterbee will use this port range unless overridden
pub const default_port_range = #(9222, 9232)

/// Butterbee will use this port unless overridden
pub const default_port = 9222

pub type BrowserType {
  Firefox
  // TODO: support chrome
  // Chrome
}

@internal
pub fn browser_type_decoder() -> decode.Decoder(BrowserType) {
  use browser_type <- decode.then(decode.string)
  case browser_type {
    "firefox" -> decode.success(Firefox)
    // "chrome" -> decode.success(Chrome)
    _ ->
      decode.failure(
        default_browser_type(),
        "Browser type not supported: " <> browser_type,
      )
  }
}

///
/// Returns the default browser type, firefox
///
pub fn default_browser_type() -> BrowserType {
  Firefox
}

pub fn default() -> Dict(BrowserType, BrowserConfig) {
  dict.new()
  |> dict.insert(Firefox, default_configuration())
}

@internal
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
    /// The path to the browser executable, or the name of the browser if it is in the PATH.
    cmd: String,
    /// Extra flags to pass to the browser.
    extra_flags: List(String),
    /// The host to use for the browser.
    host: String,
    /// The port range to use for the browser. 
    /// The first port in the range is the minimum port to use for the browser.
    /// The second port in the range is the maximum port to use for the browser.
    port_range: #(Int, Int),
  )
}

pub fn default_configuration() -> BrowserConfig {
  BrowserConfig(
    cmd: default_cmd,
    extra_flags: [],
    host: default_host,
    port_range: default_port_range,
  )
}

@internal
pub fn configuration_options_decoder() -> decode.Decoder(BrowserConfig) {
  use cmd <- decode.optional_field("cmd", default_cmd, decode.string)
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
  decode.success(BrowserConfig(cmd:, extra_flags:, host:, port_range:))
}
