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

import butterbidi/session/types/capabilities_request.{
  type CapabilitiesRequest, CapabilitiesRequest,
}
import butterbidi/session/types/capability_request.{CapabilityRequest}
import gleam/dict
import gleam/dynamic
import gleam/option.{None, Some}

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
