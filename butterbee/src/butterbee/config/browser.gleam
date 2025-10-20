////
//// This module provides functionality for parsing and creating browser configurations
//// from TOML configuration files for WebDriver BiDi sessions.
////
//// ### TOML Configuration Format
////
//// The browser configuration is defined in a TOML configuration file under the
//// `[tools.butterbee.browser]` section of your `gleam.toml` file:
////
//// ```toml
//// # gleam.toml
////
//// [tools.butterbee.browser.firefox]
//// cmd = "firefox"
//// flags = ["-headless"]
//// host = "127.0.0.1"
//// port_range = [9222, 9282]
////
//// # NOTE: chromium is not supported yet
//// [tools.butterbee.browser.chromium]
//// cmd = "chromium"
//// flags = []
//// host = "127.0.0.1"
//// port_range = [9143, 9163]
//// ```
////

import butterbee/internal/runner/firefox
import gleam/dict.{type Dict}
import gleam/dynamic/decode

/// Butterbee will use this host url unless overridden 
pub const default_host: String = "127.0.0.1"

/// Butterbee will use this port range unless overridden
pub const default_port_range: #(Int, Int) = #(9222, 9232)

/// Butterbee will use this port unless overridden
pub const default_port: Int = 9222

///
/// Returns the default browser configuration
///
pub fn default() -> Dict(BrowserType, BrowserConfig) {
  dict.new()
  |> dict.insert(Firefox, default_configuration(Firefox))
}

pub fn default_firefox() -> Dict(BrowserType, BrowserConfig) {
  dict.new()
  |> dict.insert(Firefox, default_configuration(Firefox))
}

pub type BrowserType {
  Firefox
  // TODO: support chrome
  // Chrome
}

///
/// Returns the default browser type, firefox
///
pub const default_browser_type = Firefox

@internal
pub fn browser_type_decoder() -> decode.Decoder(BrowserType) {
  use browser_type <- decode.then(decode.string)
  case browser_type {
    "firefox" -> decode.success(Firefox)
    // "chrome" -> decode.success(Chrome)
    _ ->
      decode.failure(
        default_browser_type,
        "Browser type not supported: " <> browser_type,
      )
  }
}

pub type BrowserConfig {
  BrowserConfig(
    /// The url that is loaded when the browser is started.
    start_url: String,
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

pub fn default_configuration(browser_type: BrowserType) -> BrowserConfig {
  let cmd = case browser_type {
    Firefox -> firefox.default_cmd
  }

  let default_start_url = case browser_type {
    Firefox -> firefox.default_start_url
  }

  BrowserConfig(
    start_url: default_start_url,
    cmd: cmd,
    extra_flags: [],
    host: default_host,
    port_range: default_port_range,
  )
}

pub fn with_start_url(config: BrowserConfig, start_url: String) -> BrowserConfig {
  BrowserConfig(..config, start_url:)
}

pub fn with_cmd(config: BrowserConfig, cmd: String) -> BrowserConfig {
  BrowserConfig(..config, cmd:)
}

pub fn with_extra_flags(
  config: BrowserConfig,
  extra_flags: List(String),
) -> BrowserConfig {
  BrowserConfig(..config, extra_flags:)
}

pub fn with_host(config: BrowserConfig, host: String) -> BrowserConfig {
  BrowserConfig(..config, host:)
}

pub fn with_port_range(
  config: BrowserConfig,
  port_range: #(Int, Int),
) -> BrowserConfig {
  BrowserConfig(..config, port_range:)
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

@internal
pub fn configuration_options_decoder() -> decode.Decoder(BrowserConfig) {
  use start_url <- decode.optional_field(
    "start_url",
    firefox.default_start_url,
    decode.string,
  )
  use cmd <- decode.optional_field("cmd", firefox.default_cmd, decode.string)
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
  decode.success(BrowserConfig(
    start_url:,
    cmd:,
    extra_flags:,
    host:,
    port_range:,
  ))
}
