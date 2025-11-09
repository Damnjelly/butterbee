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
//// ### TOML Configuration Format
////
//// The capabilities are defined under the
//// `[tools.butterbee.capabilities]` section of your `gleam.toml` file:
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

import butterbee/internal/lib
import butterbidi/session/commands/new
import butterbidi/session/types/capabilities_request.{
  type CapabilitiesRequest, CapabilitiesRequest,
}
import butterbidi/session/types/capability_request.{
  type CapabilityRequest, CapabilityRequest,
}
import gleam/dict.{type Dict}
import gleam/dynamic
import gleam/dynamic/decode
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/string
import palabres as log
import tom

/// Creates a default `CapabilitiesRequest` with only the `webSocketUrl` capability for `always_match`.
pub fn default() -> CapabilitiesRequest {
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

@internal
pub fn capabilities_request_from_toml(
  config: Dict(String, tom.Toml),
) -> Option(CapabilitiesRequest) {
  // Extract always_match capabilities from [Capabilities.always_match] table
  let always_match =
    tom.get_table(config, ["Capabilities", "always_match"])
    |> option.from_result()
    |> option.map(fn(toml_cap) { capability_request_from_toml(toml_cap) })

  // Extract first_match capabilities from [[Capabilities.first_match]] array
  let first_match =
    tom.get_array(config, ["Capabilities", "first_match"])
    |> option.from_result()
    |> option.map(fn(toml_caps) {
      use cap <- list.filter_map(toml_caps)
      case cap {
        // Each first_match entry should be an inline table
        tom.InlineTable(cap) -> Ok(capability_request_from_toml(cap))
        _ -> {
          log.error("Could not parse Capabilities.first_match")
          |> log.string("value", string.inspect(cap))
          |> log.log
          Error(Nil)
        }
      }
    })

  // Return capabilities request if either always_match or first_match is present
  case always_match, first_match {
    None, None -> {
      log.debug("No capabilities found")
      |> log.log
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
  // Convert TOML dictionary to dynamic properties for decoding
  let dynamic_cap =
    dict.to_list(toml_cap)
    |> list.map(fn(entry) {
      let #(key, value) = entry
      #(dynamic.string(key), lib.toml_to_dynamic(value))
    })
    |> dynamic.properties()

  // Extract extensible capabilities (vendor-specific capabilities like "goog:chromeOptions")
  let extensible =
    decode.run(dynamic_cap, new.extensible_capabilities_decoder())
    |> result.unwrap(dict.new())

  // Parse standard WebDriver(state) capabilities
  let capabilities =
    decode.run(dynamic_cap, capability_request.capability_request_decoder())
    |> result.map(fn(capabilities) {
      // Merge standard capabilities with extensible ones
      CapabilityRequest(..capabilities, extensible:)
    })

  // Handle parsing results with fallback for errors
  case capabilities {
    Ok(capabilities) -> capabilities
    Error(error) -> {
      log.error("Could not parse Capabilities")
      |> log.string("error", string.inspect(error))
      |> log.log
      CapabilityRequest(None, None, None, None, dict.new())
    }
  }
}
