import butterbee/config
import butterbee/internal/error
import butterbee/internal/socket.{type WebDriverSocket}
import butterbidi/browsing_context/types/browsing_context.{type BrowsingContext} as _
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
    state: Result(state, error.ButterbeeError),
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
  state: Result(new_state, error.ButterbeeError),
) -> WebDriver(new_state) {
  WebDriver(..webdriver, state: state)
}

pub fn map_state(
  state: Result(new_state, error.ButterbeeError),
  webdriver: WebDriver(state),
) -> WebDriver(new_state) {
  WebDriver(..webdriver, state:)
}

pub fn with_socket(
  webdriver: WebDriver(state),
  socket: WebDriverSocket,
) -> WebDriver(state) {
  WebDriver(..webdriver, socket: Some(socket))
}

pub fn get_socket(
  driver: WebDriver(state),
) -> Result(WebDriverSocket, error.ButterbeeError) {
  case driver.socket {
    None -> Error(error.DriverDoesNotHaveSocket)
    Some(socket) -> Ok(socket)
  }
}

pub fn get_context(
  driver: WebDriver(state),
) -> Result(BrowsingContext, error.ButterbeeError) {
  case driver.context {
    None -> Error(error.DriverDoesNotHaveContext)
    Some(context) -> Ok(context)
  }
}

pub fn get_config(
  driver: WebDriver(state),
) -> Result(config.ButterbeeConfig, error.ButterbeeError) {
  case driver.config {
    None -> Error(error.DriverDoesNotHaveConfig)
    Some(config) -> Ok(config)
  }
}

pub fn get_state(
  webdriver: WebDriver(state),
) -> Result(state, error.ButterbeeError) {
  webdriver.state
}

pub fn do(webdriver: WebDriver(state), action: fn(_) -> WebDriver(new_state)) {
  action(webdriver)
}
