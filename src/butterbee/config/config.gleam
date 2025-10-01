////
//// The config module contains the ButterbeeConfig type and functions
//// to parse the butterbee.toml file
////
//// For documentation see the individual config modules for more details:
//// - [Browser Config](browser_config.html)
//// - [Capabilities Config](capabilities_config.html)
//// - [Driver Config](driver_config.html)
////

import butterbee/bidi/session/types/capabilities_request.{
  type CapabilitiesRequest, capabilities_request_decoder,
}
import butterbee/config/browser_config
import butterbee/config/driver_config.{driver_config_decoder}
import butterbee/internal/lib
import gleam/dict.{type Dict}
import gleam/dynamic/decode
import gleam/option.{type Option, None, Some}
import gleam/result
import simplifile
import tom

/// 
/// Represents the butterbee.toml file
///
pub type ButterbeeConfig {
  ButterbeeConfig(
    driver_config: driver_config.DriverConfig,
    capabilities: Option(CapabilitiesRequest),
    browser_config: Option(
      Dict(browser_config.BrowserType, browser_config.BrowserConfig),
    ),
  )
}

fn butterbee_config_decoder() -> decode.Decoder(ButterbeeConfig) {
  use driver_config <- decode.optional_field(
    "Driver",
    driver_config.default(),
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
    decode.optional(browser_config.browser_config_decoder()),
  )
  decode.success(ButterbeeConfig(driver_config:, capabilities:, browser_config:))
}

pub fn default() -> ButterbeeConfig {
  ButterbeeConfig(driver_config.default(), None, None)
}

pub type Error {
  ReadError(simplifile.FileError)
  ParseError(tom.ParseError)
  DecodeError(List(decode.DecodeError))
}

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
