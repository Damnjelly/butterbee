import butterbee/config
import butterbee/internal/socket.{type WebDriverSocket}
import butterbidi/browsing_context/types/browsing_context.{type BrowsingContext} as _
import butterbidi/definition
import gleam/option.{type Option, None, Some}

///
/// Represents a webdriver session
///
pub type WebDriver(state) {
  WebDriver(
    /// The socket to the webdriver server
    socket: Option(WebDriverSocket),
    /// The browsing context of the webdriver session
    context: Option(BrowsingContext),
    /// The config used during the webdriver session
    config: Option(config.ButterbeeConfig),
    /// Some state that is returned from a command (e.g. inner_text() fills state with Some(String))
    state: Result(state, definition.ErrorResponse),
  )
}

/// Signals that the webdriver session holds no state
pub type Empty {
  Empty
}

pub fn new() -> WebDriver(Empty) {
  WebDriver(None, None, None, Ok(Empty))
}

pub fn with_context(
  webdriver: WebDriver(state),
  context: BrowsingContext,
) -> WebDriver(state) {
  WebDriver(..webdriver, context: Some(context))
}

pub fn with_config(
  webdriver: WebDriver(state),
  config: config.ButterbeeConfig,
) -> WebDriver(state) {
  WebDriver(..webdriver, config: Some(config))
}

pub fn with_state(
  webdriver: WebDriver(state),
  state: Result(new_state, definition.ErrorResponse),
) -> WebDriver(new_state) {
  WebDriver(..webdriver, state: state)
}

pub fn map_state(
  state: Result(new_state, definition.ErrorResponse),
  webdriver: WebDriver(state),
) -> WebDriver(new_state) {
  WebDriver(..webdriver, state:)
}

pub fn assert_state(webdriver: WebDriver(state)) -> state {
  let assert Ok(state) = webdriver.state as "Webdriver state is error"
  state
}

pub fn with_socket(
  webdriver: WebDriver(state),
  socket: WebDriverSocket,
) -> WebDriver(state) {
  WebDriver(..webdriver, socket: Some(socket))
}

pub fn get_socket(webdriver: WebDriver(state)) -> WebDriverSocket {
  let assert Some(socket) = webdriver.socket as "Webdriver has no socket"
  socket
}

pub fn get_context(webdriver: WebDriver(state)) -> BrowsingContext {
  let assert Some(context) = webdriver.context as "Webdriver has no context"
  context
}

pub fn get_config(webdriver: WebDriver(state)) -> config.ButterbeeConfig {
  let assert Some(config) = webdriver.config as "Webdriver has no config"
  config
}

pub fn do(webdriver: WebDriver(state), action: fn(_) -> WebDriver(new_state)) {
  action(webdriver)
}
