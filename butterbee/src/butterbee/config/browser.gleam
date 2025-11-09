//// This module provides functionality for parsing and creating browser configurations
//// from TOML configuration files for WebDriver BiDi sessions.
////
//// ### Chromium support
////
//// Because chromium does not natively support WebDriver BiDi, 
//// butterbee uses the [chromedriver](https://chromedriver.chromium.org/downloads)
//// to control chromium. Which has a BiDi to CDP mapper built in.
////
//// Chromedriver does not come with chromium built in, so make sure you have chromium installed.
//// Chromedriver will search for the chromium binary on your system. so no additional 
//// configuration is needed.
////
//// ### TOML Configuration Format
////
//// The browser configuration is defined under the
//// `[tools.butterbee.browser]` section of your `gleam.toml` file:
////
//// ```toml
//// # gleam.toml
////
//// [tools.butterbee.browser.firefox]
//// cmd = "firefox"
//// flags = ["-headless"]
//// host = "127.0.0.1"
////
//// [tools.butterbee.browser.chromium]
//// cmd = "chromedriver"
//// flags = []
//// host = "127.0.0.1"
//// ```
////
//// #### Headless
//// to run the browsers headless, add the following to your `gleam.toml` file:
////
//// ```toml
//// [tools.butterbee.browser.firefox]
//// flags = ["-headless"]
////
//// [tools.butterbee.capabilities.always_match]
//// webSocketUrl = true
//// "goog:chromeOptions" = { args = ["--headless=new"] }
//// ```

import butterbee/internal/runner/chromium
import butterbee/internal/runner/firefox
import gleam/dict.{type Dict}
import gleam/dynamic/decode
import palabres as logger

/// Butterbee will use this host url unless overridden 
pub const default_host: String = "127.0.0.1"

/// Butterbee will use this port unless overridden
pub const default_port: Int = 9222

/// Returns the default browser configuration
pub fn default() -> Dict(BrowserType, BrowserConfig) {
  dict.new()
  |> dict.insert(Firefox, default_configuration(Firefox))
  |> dict.insert(Chromium, default_configuration(Chromium))
}

pub type BrowserType {
  Firefox
  Chromium
}

/// Returns the default browser type, firefox
pub const default_browser_type = Firefox

@internal
pub fn browser_type_decoder() -> decode.Decoder(BrowserType) {
  use browser_type <- decode.then(decode.string)
  case browser_type {
    "firefox" -> decode.success(Firefox)
    "chromium" -> decode.success(Chromium)
    _ -> {
      logger.error("Browser type not supported")
      |> logger.string("browser_type", browser_type)
      |> logger.log
      decode.failure(default_browser_type, "Browser type not supported")
    }
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
  )
}

pub fn default_configuration(browser_type: BrowserType) -> BrowserConfig {
  let cmd = case browser_type {
    Firefox -> firefox.default_cmd
    Chromium -> chromium.default_cmd
  }

  let default_start_url = case browser_type {
    Firefox -> firefox.default_start_url
    Chromium -> chromium.default_start_url
  }

  BrowserConfig(
    start_url: default_start_url,
    cmd: cmd,
    extra_flags: [],
    host: default_host,
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

@internal
pub fn browser_config_decoder() -> decode.Decoder(
  Dict(BrowserType, BrowserConfig),
) {
  use firefox_config <- decode.optional_field(
    "firefox",
    default_configuration(Firefox),
    configuration_options_decoder(Firefox),
  )
  use chromium_config <- decode.optional_field(
    "chromium",
    default_configuration(Chromium),
    configuration_options_decoder(Chromium),
  )
  decode.success(
    dict.new()
    |> dict.insert(Firefox, firefox_config)
    |> dict.insert(Chromium, chromium_config),
  )
}

@internal
pub fn configuration_options_decoder(
  browser_type: BrowserType,
) -> decode.Decoder(BrowserConfig) {
  let BrowserConfig(start_url, cmd, extra_flags, host) =
    default_configuration(browser_type)
  use start_url <- decode.optional_field("start_url", start_url, decode.string)
  use cmd <- decode.optional_field("cmd", cmd, decode.string)
  use extra_flags <- decode.optional_field(
    "flags",
    extra_flags,
    decode.list(decode.string),
  )
  use host <- decode.optional_field("host", host, decode.string)
  decode.success(BrowserConfig(start_url:, cmd:, extra_flags:, host:))
}
