////
//// Butterbee can be configured using the `gleam.toml` file.
//// When you call the `new` function in the webdriver module, butterbee tries 
//// to parse the `gleam.toml` file in the root of the project. If it can't find it,
//// it will use the default configuration.
////
//// For documentation see the individual config modules for more details:
//// - [Browser Config](browser_config.html)
//// - [Capabilities Config](capabilities_config.html)
//// - [Driver Config](driver_config.html)
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
//// [tools.butterbee.capabilities]
////
//// # Capabilities is empty by default
////
//// [tools.butterbee.browser.firefox]
//// flags = []
//// host = "127.0.0.1"
//// port_range = [9222, 9232]
//// ```
////

import butterbee/config/browser
import butterbee/config/driver.{driver_config_decoder}
import butterbee/internal/lib
import butterbidi/session/types/capabilities_request.{
  type CapabilitiesRequest, capabilities_request_decoder,
}
import butterlib/log
import gleam/dict.{type Dict}
import gleam/dynamic/decode
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/string
import simplifile
import tom

/// 
/// Represents the [tools.butterbee] section of your gleam.toml file
///
pub type ButterbeeConfig {
  ButterbeeConfig(
    driver: driver.DriverConfig,
    capabilities: Option(CapabilitiesRequest),
    browser_config: Option(Dict(browser.BrowserType, browser.BrowserConfig)),
  )
}

pub fn with_driver_config(
  config: ButterbeeConfig,
  driver: driver.DriverConfig,
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
  browser_config: Dict(browser.BrowserType, browser.BrowserConfig),
) -> ButterbeeConfig {
  ButterbeeConfig(..config, browser_config: Some(browser_config))
}

fn butterbee_config_decoder() -> decode.Decoder(ButterbeeConfig) {
  use driver <- decode.optional_field(
    "driver",
    driver.default,
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
    decode.optional(browser.browser_config_decoder()),
  )
  decode.success(ButterbeeConfig(driver:, capabilities:, browser_config:))
}

/// 
/// The default config.
/// See the toml representation of the default configuration above
///
pub const default: ButterbeeConfig = ButterbeeConfig(driver.default, None, None)

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

  use config <- result.try({ tom.parse(path) |> result.map_error(ParseError) })

  let config = lib.toml_to_dynamic(tom.Table(config))
  log.debug("Butterbee config: \n" <> string.inspect(config))

  let decoder = decode.at(["tools", "butterbee"], butterbee_config_decoder())

  use config <- result.try({
    decode.run(config, decoder)
    |> result.map_error(DecodeError)
  })
  log.debug("Butterbee config: \n" <> string.inspect(config))

  Ok(config)
}
