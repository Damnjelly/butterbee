import butterbee/bidi/session/commands/new
import butterbee/bidi/session/types/capabilities_request.{
  type CapabilitiesRequest,
}
import butterbee/bidi/session/types/capability_request.{type CapabilityRequest}
import butterbee/internal/browser.{type Browser}
import gleam/dict.{type Dict}
import gleam/dynamic
import gleam/dynamic/decode
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/string
import logging
import simplifile
import tom

pub type ButterbeeConfig {
  ButterbeeConfig(
    driver_config: DriverConfig,
    capabilities: Option(CapabilitiesRequest),
  )
}

pub fn parse_config(path: String) -> ButterbeeConfig {
  let assert Ok(path) = simplifile.read(path)
    as "Could not read butterbee.toml file"

  let assert Ok(config) = tom.parse(path)
    as "Could not parse butterbee.toml file"

  let driver_config = driver_config_from_toml(config)
  let capabilities = capabilities_request_from_toml(config)

  ButterbeeConfig(driver_config, capabilities: capabilities)
}

pub type DriverConfig {
  DriverConfig(
    browser: Option(Browser),
    max_wait_time: Int,
    request_timeout: Int,
    data_dir: String,
  )
}

fn driver_config_from_toml(config: Dict(String, tom.Toml)) -> DriverConfig {
  let browser =
    tom.get_string(config, ["Driver", "browser"])
    |> option.from_result()
    |> option.map(fn(browser) { browser_from_toml(browser, config) })

  let max_wait_time =
    tom.get_int(config, ["Driver", "max_wait_time"])
    |> result.unwrap(20_000)

  let request_timeout =
    tom.get_int(config, ["Driver", "request_timeout"])
    |> result.unwrap(5000)

  let data_dir =
    tom.get_string(config, ["Driver", "data_dir"])
    |> result.unwrap("/tmp/butterbee")

  DriverConfig(browser:, max_wait_time:, request_timeout:, data_dir:)
}

fn browser_from_toml(browser: String, config: Dict(String, tom.Toml)) -> Browser {
  let host =
    tom.get_string(config, ["Browsers", browser, "host"])
    |> result.unwrap(browser.default_host)

  let port_range_to_toml = fn(port_range) {
    case port_range {
      [tom.Int(port_start), tom.Int(port_end)] -> #(port_start, port_end)
      _ -> {
        logging.log(
          logging.Error,
          "Could not parse port_range for: "
            <> browser
            <> " , expected array of length 2",
        )
        browser.default_port_range
      }
    }
  }

  let port_range =
    tom.get_array(config, ["Browsers", browser, "port_range"])
    |> result.map(port_range_to_toml)
    |> result.unwrap(browser.default_port_range)

  let default_browser = browser.default()

  case browser {
    "firefox" ->
      browser.Browser(..default_browser, browser_type: browser.Firefox)
    "chrome" -> browser.Browser(..default_browser, browser_type: browser.Chrome)
    _ -> {
      logging.log(logging.Error, "Browser: " <> browser <> " is not supported")
      default_browser
    }
  }
}

fn capabilities_request_from_toml(
  config: Dict(String, tom.Toml),
) -> Option(CapabilitiesRequest) {
  let always_match =
    tom.get_table(config, ["Capabilities", "always_match"])
    |> option.from_result()
    |> option.map(fn(toml_cap) { capability_request_from_toml(toml_cap) })

  let first_match =
    tom.get_array(config, ["Capabilities", "first_match"])
    |> option.from_result()
    |> option.map(fn(toml_caps) {
      use cap <- list.filter_map(toml_caps)
      case cap {
        tom.InlineTable(cap) -> Ok(capability_request_from_toml(cap))
        _ -> {
          logging.log(
            logging.Error,
            "Could not parse Capabilities.first_match, expected InlineTable, got "
              <> string.inspect(cap),
          )
          Error(Nil)
        }
      }
    })

  case always_match, first_match {
    None, None -> {
      logging.log(logging.Debug, "No capabilities found")
      None
    }
    _, _ -> {
      Some(capabilities_request.CapabilitiesRequest(always_match:, first_match:))
    }
  }
}

fn capability_request_from_toml(
  toml_cap: Dict(String, tom.Toml),
) -> CapabilityRequest {
  let dynamic_cap =
    dict.to_list(toml_cap)
    |> list.map(fn(entry) {
      let #(key, value) = entry
      #(dynamic.string(key), toml_unwrap(value))
    })
    |> dynamic.properties()

  let extensible =
    decode.run(dynamic_cap, new.extensible_capabilities_decoder())
    |> result.unwrap(dict.new())

  let capabilities =
    decode.run(dynamic_cap, capability_request.capability_request_decoder())
    |> result.map(fn(capabilities) {
      capability_request.CapabilityRequest(..capabilities, extensible:)
    })

  case capabilities {
    Ok(capabilities) -> capabilities
    Error(error) -> {
      logging.log(
        logging.Error,
        "Could not parse Capabilities, error: " <> string.inspect(error) <> "
     Replacing with empty CapabilityRequest",
      )
      capability_request.CapabilityRequest(None, None, None, None, dict.new())
    }
  }
}

fn toml_unwrap(value: tom.Toml) -> dynamic.Dynamic {
  case value {
    tom.String(value) -> dynamic.string(value)
    tom.Int(value) -> dynamic.int(value)
    tom.Float(value) -> dynamic.float(value)
    tom.Bool(value) -> dynamic.bool(value)
    tom.InlineTable(value) ->
      dynamic.properties({
        value
        |> dict.to_list()
        |> list.map(fn(entry) {
          let #(key, value) = entry
          #(dynamic.string(key), toml_unwrap(value))
        })
      })
    _ -> {
      logging.log(
        logging.Error,
        "Could not unwrap value: " <> string.inspect(value) <> "
     Replacing with empty string",
      )

      dynamic.string("")
    }
  }
}
