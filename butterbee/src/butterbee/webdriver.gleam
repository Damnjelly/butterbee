//// The webdriver module contains the WebDriver type and functions to create and configure webdriver sessions.

import butterbee/config
import butterbee/internal/browser
import butterbee/internal/error
import butterbee/internal/socket.{type WebDriverSocket}
import butterbidi/browsing_context/types/browsing_context.{type BrowsingContext} as _
import gleam/option.{type Option, None, Some}

/// Represents a webdriver session
pub type WebDriver(state) {
  WebDriver(
    /// The socket to the webdriver server
    socket: WebDriverSocket,
    /// The browsing context of the webdriver session
    context: Option(BrowsingContext),
    /// The config used during the webdriver session
    config: config.ButterbeeConfig,
    /// Some state that is returned from a command (e.g. `node.value()` fills state with 
    ///Result(String, error.ButterbeeError))
    state: Result(state, error.ButterbeeError),
    browser: browser.Browser,
  )
}

/// Signals that the webdriver session holds no state
@internal
pub type Empty {
  Empty
}

@internal
pub fn new(
  socket: WebDriverSocket,
  config: config.ButterbeeConfig,
  browser: browser.Browser,
) -> WebDriver(Empty) {
  WebDriver(
    socket: socket,
    context: None,
    config: config,
    state: Ok(Empty),
    browser: browser,
  )
}

@internal
pub fn with_socket(
  webdriver: WebDriver(state),
  socket: WebDriverSocket,
) -> WebDriver(state) {
  WebDriver(..webdriver, socket: socket)
}

@internal
pub fn with_context(
  webdriver: WebDriver(state),
  context: BrowsingContext,
) -> WebDriver(state) {
  WebDriver(..webdriver, context: Some(context))
}

@internal
pub fn with_config(
  webdriver: WebDriver(state),
  config: config.ButterbeeConfig,
) -> WebDriver(state) {
  WebDriver(..webdriver, config: config)
}

@internal
pub fn with_state(
  webdriver: WebDriver(state),
  state: Result(new_state, error.ButterbeeError),
) -> WebDriver(new_state) {
  WebDriver(..webdriver, state: state)
}

@internal
pub fn with_browser(
  webdriver: WebDriver(state),
  browser: browser.Browser,
) -> WebDriver(state) {
  WebDriver(..webdriver, browser: browser)
}

@internal
pub fn map_state(
  state: Result(new_state, error.ButterbeeError),
  webdriver: WebDriver(state),
) -> WebDriver(new_state) {
  WebDriver(..webdriver, state:)
}

/// Perform an action using the webdriver and update the webdriver state
@internal
pub fn do(webdriver: WebDriver(state), action: fn(_) -> WebDriver(new_state)) {
  action(webdriver)
}
