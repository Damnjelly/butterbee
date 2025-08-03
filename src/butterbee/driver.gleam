//// The driver module contains high-level commands for interacting with the webdriver server

import butterbee/bidi/browsing_context/commands/browsing_context.{
  GetTreeParameters,
}
import butterbee/bidi/browsing_context/types/browsing_context.{
  type BrowsingContext,
} as _
import butterbee/bidi/browsing_context/types/readiness_state
import butterbee/bidi/session/commands/session
import butterbee/bidi/session/types/capabilities_request.{CapabilitiesRequest}
import butterbee/bidi/session/types/capability_request.{CapabilityRequest}
import butterbee/internal/config
import butterbee/internal/socket.{type WebDriverSocket}
import gleam/erlang/process
import gleam/list
import gleam/option.{None, Some}

pub type WebDriver {
  WebDriver(
    socket: WebDriverSocket,
    context: BrowsingContext,
    // config: config.ButterbeeConfig,
  )
}

/// Start a new webdriver session connect to the browse session
pub fn new() -> WebDriver {
  config.parse_config("butterbee.toml")
  let session =
    session.new(CapabilitiesRequest(
      Some(CapabilityRequest(None, None, None, None, [])),
      None,
    ))

  let browsing_tree =
    browsing_context.get_tree(session.0, GetTreeParameters(None, None))

  let context = case list.length(browsing_tree.contexts) {
    1 -> {
      let assert Ok(context) = list.first(browsing_tree.contexts)
        as "Found no browsing contexts"
      context
    }
    _ -> panic as "Found more than one, or zero, browsing contexts"
  }

  WebDriver(session.0, context)
}

pub fn goto(driver: WebDriver, url: String) -> WebDriver {
  let new_driver =
    browsing_context.navigate(
      driver.socket,
      browsing_context.NavigateParameters(
        context: driver.context,
        url: url,
        wait: Some(readiness_state.Interactive),
      ),
    )

  WebDriver(new_driver.0, new_driver.1)
}

pub fn wait(state: state, duration: Int) -> state {
  process.sleep(duration)
  state
}

pub fn end(driver_with_state: #(WebDriver, state)) -> state {
  session.end({ driver_with_state.0 }.socket)
  driver_with_state.1
}
