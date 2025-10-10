////
//// The config module contains the ButterbeeConfig type and functions
//// to parse the butterbee.toml file
////
//// For documentation see the individual config modules for more details:
//// - [Browser Config](browser_config.html)
//// - [Capabilities Config](capabilities_config.html)
//// - [Driver Config](driver_config.html)
////
//// Example of the default settings in toml format:
////
//// ```toml
//// [Driver]
//// max_wait_time = 20000
//// request_timeout = 5000
//// data_dir = "/tmp/butterbee"
////
//// [Capabilities]
////
//// # Capabilities is empty by default
////
//// [Browsers]
////
//// [Browsers.firefox]
////
//// flags = []
//// host = "127.0.0.1"
//// port_range = [9222, 9232]
////
//// [Browsers.chrome]
////
//// # Chrome is not supported yet
////
//// ```
////

import butterbee/config/browser
import butterbee/config/driver.{driver_config_decoder}
import butterbee/internal/lib
import butterbidi/session/types/capabilities_request.{
  type CapabilitiesRequest, capabilities_request_decoder,
}
import gleam/dict.{type Dict}
import gleam/dynamic/decode
import gleam/option.{type Option, None}
import gleam/result
import simplifile
import tom

/// 
/// Represents the butterbee.toml file
///
pub type ButterbeeConfig {
  ButterbeeConfig(
    driver: driver.DriverConfig,
    capabilities: Option(CapabilitiesRequest),
    browser_config: Option(Dict(browser.BrowserType, browser.BrowserConfig)),
  )
}

fn butterbee_config_decoder() -> decode.Decoder(ButterbeeConfig) {
  use driver <- decode.optional_field(
    "Driver",
    driver.default(),
    driver_config_decoder(),
  )
  use capabilities <- decode.optional_field(
    "Capabilities",
    None,
    decode.optional(capabilities_request_decoder()),
  )
  use browser_config <- decode.optional_field(
    "Browsers",
    None,
    decode.optional(browser.browser_config_decoder()),
  )
  decode.success(ButterbeeConfig(driver:, capabilities:, browser_config:))
}

/// 
/// Returns the default configuration
/// See the toml representation of the default configuration above
///
pub fn default() -> ButterbeeConfig {
  ButterbeeConfig(driver.default(), None, None)
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

  use config <- result.try({ tom.parse(path) |> result.map_error(ParseError) })

  let config = lib.toml_to_dynamic(tom.Table(config))

  use config <- result.try({
    decode.run(config, butterbee_config_decoder())
    |> result.map_error(DecodeError)
  })

  Ok(config)
}
