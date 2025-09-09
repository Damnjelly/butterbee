import butterbee/bidi/session/commands/new
import butterbee/bidi/session/types/capabilities_request.{
  type CapabilitiesRequest, CapabilitiesRequest,
}
import butterbee/bidi/session/types/capability_request.{
  type CapabilityRequest, CapabilityRequest,
}
import butterbee/internal/lib
import gleam/dict.{type Dict}
import gleam/dynamic
import gleam/dynamic/decode
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/string
import logging
import tom

pub fn default() -> CapabilitiesRequest {
  CapabilitiesRequest(None, None)
}

pub fn capabilities_request_from_toml(
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
      Some(CapabilitiesRequest(always_match:, first_match:))
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
      #(dynamic.string(key), lib.toml_to_dynamic(value))
    })
    |> dynamic.properties()

  let extensible =
    decode.run(dynamic_cap, new.extensible_capabilities_decoder())
    |> result.unwrap(dict.new())

  let capabilities =
    decode.run(dynamic_cap, capability_request.capability_request_decoder())
    |> result.map(fn(capabilities) {
      CapabilityRequest(..capabilities, extensible:)
    })

  case capabilities {
    Ok(capabilities) -> capabilities
    Error(error) -> {
      logging.log(
        logging.Error,
        "Could not parse Capabilities, error: " <> string.inspect(error) <> "
     Replacing with empty CapabilityRequest",
      )
      CapabilityRequest(None, None, None, None, dict.new())
    }
  }
}
