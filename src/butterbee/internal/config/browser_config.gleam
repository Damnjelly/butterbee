import butterbee/internal/browser
import gleam/dict.{type Dict}
import gleam/dynamic/decode
import gleam/list
import gleam/result
import logging
import tom

pub type BrowsersConfig {
  BrowsersConfig(Dict(browser.BrowserType, ConfigurationOptions))
}

pub fn browser_config_decoder() -> decode.Decoder(BrowsersConfig) {
  use browser_config <- decode.then(decode.dict(
    browser.browser_type_decoder(),
    configuration_options_decoder(),
  ))
  decode.success(BrowsersConfig(browser_config))
}

pub fn default() -> BrowsersConfig {
  BrowsersConfig(dict.new())
}

pub type ConfigurationOptions {
  ConfigurationOptions(
    extra_flags: List(String),
    host: String,
    port_range: #(Int, Int),
  )
}

pub fn configuration_options_decoder() -> decode.Decoder(ConfigurationOptions) {
  use extra_flags <- decode.field("flags", decode.list(decode.string))
  use host <- decode.field("host", decode.string)
  use port_range <- decode.field("port_range", {
    use a <- decode.field(0, decode.int)
    use b <- decode.field(1, decode.int)

    decode.success(#(a, b))
  })
  decode.success(ConfigurationOptions(extra_flags:, host:, port_range:))
}

pub fn browser_config_from_toml(
  browser: String,
  config: Dict(String, tom.Toml),
) -> ConfigurationOptions {
  let extra_flags =
    tom.get_array(config, ["Browsers", browser, "flags"])
    |> result.map(extra_flags_from_toml)
    |> result.unwrap(list.new())

  let host =
    tom.get_string(config, ["Browsers", browser, "host"])
    |> result.unwrap(browser.default_host)

  let port_range =
    tom.get_array(config, ["Browsers", browser, "port_range"])
    |> result.map(port_range_from_toml)
    |> result.unwrap(browser.default_port_range)

  ConfigurationOptions(extra_flags:, host:, port_range:)
  // TODO: This should not be here
  // let default_browser = browser.default()
  //
  // let configured_browser =
  //   browser.Browser(
  //     ..default_browser,
  //     extra_flags: Some(extra_flags),
  //     port_range:,
  //   )
  //
  // case browser {
  //   "firefox" -> configured_browser
  //   "chrome" ->
  //     browser.Browser(..configured_browser, browser_type: browser.Chrome)
  //   _ -> {
  //     logging.log(
  //       logging.Error,
  //       "Browser: "
  //         <> browser
  //         <> " is not supported, using default configuration",
  //     )
  //     default_browser
  //   }
  // }
}

fn extra_flags_from_toml(flags) {
  case flags {
    [tom.String(flag)] -> [flag]
    _ -> {
      logging.log(
        logging.Error,
        "Could not parse flags, expected array strings",
      )
      []
    }
  }
}

fn port_range_from_toml(port_range) {
  case port_range {
    [tom.Int(port_start), tom.Int(port_end)] -> #(port_start, port_end)
    _ -> {
      logging.log(
        logging.Error,
        "Could not parse port range, expected array of length 2",
      )
      browser.default_port_range
    }
  }
}
