import butterbee/bidi/browsing_context/types/browsing_context.{
  type BrowsingContext,
} as _
import butterbee/internal/config/config
import butterbee/internal/socket.{type WebDriverSocket}

///
/// Represents a webdriver session
///
pub type WebDriver {
  WebDriver(
    /// The socket to the webdriver server
    socket: WebDriverSocket,
    /// The browsing context of the webdriver session
    context: BrowsingContext,
    /// The config used during the webdriver session
    config: config.ButterbeeConfig,
  )
}

pub fn new(
  socket: WebDriverSocket,
  context: BrowsingContext,
  config: config.ButterbeeConfig,
) -> WebDriver {
  WebDriver(socket, context, config)
}

pub fn with_context(webdriver: WebDriver, context: BrowsingContext) -> WebDriver {
  WebDriver(..webdriver, context:)
}
