import butterbee/bidi/session/commands/session
import butterbee/internal/browsers.{type Browsers}
import butterbee/internal/runner
import gleam/dict.{type Dict}
import gleam/dynamic.{type Dynamic}
import gleam/dynamic/decode.{type Decoder}
import gleam/option.{type Option, None, Some}
import simplifile
import tom

pub type ButterbeeConfig {
  ButterbeeConfig(browsers: Browsers, capabilities: Option(CapabilitiesConfig))
}

pub fn parse_config(path: String) -> Nil {
  let assert Ok(path) = simplifile.read(path)
    as "Could not read butterbee.toml file"

  let assert Ok(toml) = tom.parse(path)
  let always_match = case
    tom.get_table(toml, ["Capabilities", "always_match"])
  {
    Ok(value) -> Some({session.capabilities_decoder(value)})
    Error(_) -> None
  }
  let first_match = case tom.get_table(toml, ["Capabilities", "first_match"]) {
    Ok(value) -> Some(value)
    Error(_) -> None
  }
  echo first_match
  todo
  Nil
}

pub type CapabilitiesConfig {
  CapabilitiesConfig(
    always_match: Option(session.Capabilities),  todo
  todo

    first_match: Option(List(session.Capabilities)),
  )
}

pub type CapabilityConfig {
  CapabilityConfig(capabilities: Dict(String, Dynamic))
}

pub type BrowsersConfig {
  ButterbeeBrowsers(Dict(browsers.Browsers, BrowserConfig))
}

pub type BrowserConfig {
  ButterbeeBrowser(host: String, port_range: #(Int, Int))
}
