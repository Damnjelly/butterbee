//// Butterbee can be configured using the `gleam.toml` file.
//// When you call the `new` function in the webdriver module, butterbee tries 
//// to parse the `gleam.toml` file in the root of the project. If it can't find it,
//// it will use the default configuration.
////
//// Example of the default configuration in toml format:
////
//// ```toml
//// # gleam.toml
////
//// [tools.butterbee.driver]
//// max_wait_time = 20000
//// request_timeout = 5000
//// data_dir = "/tmp/butterbee"
////
//// [tools.butterbee.capabilities.always_match]
//// webSocketUrl = true
////
//// [tools.butterbee.browser.firefox]
//// cmd = "firefox"
//// flags = []
//// host = "127.0.0.1"
////
//// [tools.butterbee.browser.chromium]
//// cmd = "chromedriver"
//// flags = []
//// host = "127.0.0.1"
//// ```
////
//// ## Driver Config
////
//// The driver config module contains functions for parsing and creating driver
//// configurations. The driver configuration specifies general options the webdriver
//// needs to run, such as the maximum wait time, and the request timeout.
////
//// ```toml
//// # gleam.toml
////
//// [tools.butterbee.driver]
//// max_wait_time = 20000
//// request_timeout = 5000
//// data_dir = "/tmp/butterbee"
//// ```
////
//// ## Capabilities Config
////
//// This module provides functionality for parsing and creating capabilities requests 
//// from TOML configuration files for WebDriver(state) BiDi sessions.
////
//// In browser automation contexts, **capabilities** define the desired properties 
//// and features that a WebDriver(state) session should support. They specify requirements 
//// like browser version, platform, extensions, timeouts, and other session-specific 
//// configurations. Capabilities are used during session negotiation to match the 
//// requested features with what the browser/driver can provide.
////
//// The capabilities matching process typically involves:
//// - `always_match`: Capabilities that must be satisfied for the session to be created
//// - `first_match`: A list of capability sets where at least one must be satisfied
////
//// ```toml
//// # gleam.toml
//// # TODO: add realistic example here, the current example works but is not realistic
////
//// [tools.butterbee.capabilities.always_match]
//// webSocketUrl = true
//// "goog:chromeOptions" = { args = ["--headless=new"] }
////
//// [[tools.butterbee.capabilities.first_match]]
//// browserVersion = "latest"
//// "chrome:options" = { debuggerAddress = "localhost:9222" }
////
//// [[tools.butterbee.capabilities.first_match]]
//// "moz:firefoxOptions" = { binary = "/usr/bin/firefox", args = [
////   "-headless",
////   "-safe-mode",
//// ], prefs = { "dom.webnotifications.enabled" = false }, log = { level = "trace" } }
//// browserVersion = "stable"
//// }
//// ```
////
//// ## Browser Config
////
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

import butterbee/internal/lib
import butterbee/internal/runner/chromium
import butterbee/internal/runner/firefox
import butterbidi/session/types/capabilities_request.{
  type CapabilitiesRequest, CapabilitiesRequest, capabilities_request_decoder,
}
import butterbidi/session/types/capability_request.{CapabilityRequest}
import gleam/dict.{type Dict}
import gleam/dynamic
import gleam/dynamic/decode
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/string
import palabres as logger
import simplifile
import tom

/// Represents the [tools.butterbee] section of your gleam.toml file
pub type ButterbeeConfig {
  ButterbeeConfig(
    driver: DriverConfig,
    capabilities: Option(CapabilitiesRequest),
    browser_config: Option(Dict(BrowserType, BrowserConfig)),
  )
}

/// The default config.
/// See the toml representation of the default configuration above
pub const default_config: ButterbeeConfig = ButterbeeConfig(
  default_driver_config,
  None,
  None,
)

pub fn with_driver_config(
  config: ButterbeeConfig,
  driver: DriverConfig,
) -> ButterbeeConfig {
  ButterbeeConfig(..config, driver:)
}

pub fn with_capabilities(
  config: ButterbeeConfig,
  capabilities: CapabilitiesRequest,
) -> ButterbeeConfig {
  ButterbeeConfig(..config, capabilities: Some(capabilities))
}

pub fn with_browser_config(
  config: ButterbeeConfig,
  browser_type: BrowserType,
  browser_config: BrowserConfig,
) -> ButterbeeConfig {
  let apply_config = fn(
    dict: Dict(BrowserType, BrowserConfig),
    browser_type: BrowserType,
    browser_config: BrowserConfig,
  ) {
    case browser_type {
      Firefox -> dict.insert(dict, browser_type, browser_config)
      Chromium -> dict.insert(dict, browser_type, browser_config)
    }
  }

  let browser_config = case config.browser_config {
    None -> apply_config(dict.new(), browser_type, browser_config)
    Some(existing_config) ->
      apply_config(existing_config, browser_type, browser_config)
  }

  ButterbeeConfig(..config, browser_config: Some(browser_config))
}

fn butterbee_config_decoder() -> decode.Decoder(ButterbeeConfig) {
  use driver <- decode.optional_field(
    "driver",
    default_driver_config,
    driver_config_decoder(),
  )
  use capabilities <- decode.optional_field(
    "capabilities",
    None,
    decode.optional(capabilities_request_decoder()),
  )
  use browser_config <- decode.optional_field(
    "browser",
    None,
    decode.optional(browser_config_decoder()),
  )
  decode.success(ButterbeeConfig(driver:, capabilities:, browser_config:))
}

@internal
pub type Error {
  ReadError(simplifile.FileError)
  ParseError(tom.ParseError)
  DecodeError(List(decode.DecodeError))
}

@internal
pub fn parse_config(path: String) -> Result(ButterbeeConfig, Error) {
  use path <- result.try({
    simplifile.read(path) |> result.map_error(ReadError)
  })

  parse_config_string(path)
}

@internal
pub fn parse_config_string(toml: String) -> Result(ButterbeeConfig, Error) {
  use config <- result.try({ tom.parse(toml) |> result.map_error(ParseError) })

  let config = lib.toml_to_dynamic(tom.Table(config))

  let decoder = decode.at(["tools", "butterbee"], butterbee_config_decoder())

  use config <- result.try({
    decode.run(config, decoder)
    |> result.map_error(DecodeError)
  })

  logger.debug("Butterbee config")
  |> logger.string("config", string.inspect(config))
  |> logger.log

  Ok(config)
}

// -----------------------------------------------------------------------------
// Driver Config
// -----------------------------------------------------------------------------

/// Butterbee will use this maximum wait time unless overridden.
/// This settings determines how long butterbee will perform a retry function for
/// before timing out (and failing the test).
pub const default_max_wait_time: Int = 20_000

/// Butterbee will use this request timeout unless overridden.
/// Warn: This value is not currently used.
pub const default_request_timeout: Int = 5000

/// Butterbee will use this data directory unless overridden.
/// The data directory is used to store profile data for browsers.
pub const default_data_dir: String = "/tmp/butterbee"

pub type DriverConfig {
  DriverConfig(max_wait_time: Int, request_timeout: Int, data_dir: String)
}

pub const default_driver_config: DriverConfig = DriverConfig(
  max_wait_time: default_max_wait_time,
  request_timeout: default_request_timeout,
  data_dir: default_data_dir,
)

@internal
pub fn driver_config_decoder() -> decode.Decoder(DriverConfig) {
  use max_wait_time <- decode.optional_field(
    "max_wait_time",
    default_max_wait_time,
    decode.int,
  )
  use request_timeout <- decode.optional_field(
    "request_timeout",
    default_request_timeout,
    decode.int,
  )
  use data_dir <- decode.optional_field(
    "data_dir",
    default_data_dir,
    decode.string,
  )

  decode.success(DriverConfig(max_wait_time:, request_timeout:, data_dir:))
}

// -----------------------------------------------------------------------------
// Capabilities Config
// -----------------------------------------------------------------------------

/// Creates a default `CapabilitiesRequest` with only the `webSocketUrl` capability for `always_match`.
pub fn default_capabilities_config() -> CapabilitiesRequest {
  CapabilitiesRequest(
    always_match: Some(
      CapabilityRequest(
        ..capability_request.default(),
        extensible: dict.new()
          |> dict.insert("webSocketUrl", dynamic.bool(True)),
      ),
    ),
    first_match: None,
  )
}

// -----------------------------------------------------------------------------
// Browser Config
// -----------------------------------------------------------------------------

/// Butterbee will use this host url unless overridden 
pub const default_host: String = "127.0.0.1"

/// Butterbee will use this port unless overridden
pub const default_port: Int = 9222

/// Returns the default browser configuration
pub fn default_browser_config() -> Dict(BrowserType, BrowserConfig) {
  dict.new()
  |> dict.insert(Firefox, default_individual_browser_config(Firefox))
  |> dict.insert(Chromium, default_individual_browser_config(Chromium))
}

pub type BrowserType {
  Firefox
  Chromium
}

@internal
pub fn browser_type_to_string(browser_type: BrowserType) -> String {
  case browser_type {
    Firefox -> "firefox"
    Chromium -> "chromium"
  }
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

@internal
pub fn default_individual_browser_config(
  browser_type: BrowserType,
) -> BrowserConfig {
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
    default_individual_browser_config(Firefox),
    configuration_options_decoder(Firefox),
  )
  use chromium_config <- decode.optional_field(
    "chromium",
    default_individual_browser_config(Chromium),
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
    default_individual_browser_config(browser_type)
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
