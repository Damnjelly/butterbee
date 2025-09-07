//// The driver module contains high-level commands for interacting with the webdriver server

import butterbee/bidi/browsing_context/commands/get_tree
import butterbee/bidi/browsing_context/commands/navigate
import butterbee/bidi/browsing_context/types/browsing_context.{
  type BrowsingContext,
} as _
import butterbee/bidi/browsing_context/types/readiness_state
import butterbee/bidi/session/types/capabilities_request
import butterbee/commands/browser
import butterbee/commands/browsing_context
import butterbee/commands/session
import butterbee/internal/config
import butterbee/internal/lib
import butterbee/internal/runner
import butterbee/internal/socket.{type WebDriverSocket}
import gleam/erlang/process
import gleam/list
import gleam/option.{None, Some}

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

///
/// Start a new webdriver session connect to the browser session, using the given config
/// 
/// # Example
///
/// This example starts a new webdriver session, connects to the browser session, and returns the webdriver session:
///
/// ```gleam
/// let example = driver.new_with_config("test/special_config.toml")
/// ```
///
pub fn new_with_config(path: String) -> WebDriver {
  abstract_new(path: path)
}

///
/// Start a new webdriver session connect to the browser session, using the config located in root of the project
/// 
pub fn new() -> WebDriver {
  abstract_new(path: "butterbee.toml")
}

fn abstract_new(path path: String) -> WebDriver {
  let config = config.parse_config(path)

  let capabilities =
    config.capabilities
    |> option.unwrap(capabilities_request.CapabilitiesRequest(None, None))

  let assert Ok(request) = runner.start(config.driver_config)

  let #(socket, response) = session.new(request, capabilities)

  let assert Ok(_) = response

  let assert Ok(info_list) =
    browsing_context.get_tree(socket, get_tree.GetTreeParameters(Some(1), None))

  let context = case list.length(info_list.contexts.list) {
    1 -> {
      let assert Ok(info) = list.first(info_list.contexts.list)
        as "Found no browsing contexts"
      info.context
    }
    _ -> panic as "Found more than one, or zero, browsing contexts"
  }

  WebDriver(socket, context, config)
}

pub fn get_url(driver: WebDriver) -> #(WebDriver, String) {
  let assert Ok(get_tree_result) =
    browsing_context.get_tree(
      driver.socket,
      get_tree.GetTreeParameters(None, None),
    )

  let assert Ok(info) = lib.single_element(get_tree_result.contexts.list)
    as "Found more than one, or zero, browsing contexts"

  #(driver, info.url)
}

///
/// Navigates to the given url
/// 
/// # Example
///
/// This example navigates to the gleam website:
///
/// ```gleam
/// let example =
///   driver.new()
///   |> driver.goto("https://gleam.run/")
/// ```
///
pub fn goto(driver: WebDriver, url: String) -> WebDriver {
  let _ =
    browsing_context.navigate(
      driver.socket,
      navigate.NavigateParameters(
        context: driver.context,
        url: url,
        wait: Some(readiness_state.Interactive),
      ),
    )

  driver
}

///
/// Waits for a given amount of time (in milliseconds) before continuing
/// 
/// # Example
///
/// This example waits for 2 seconds before continuing:
///
/// ```gleam
/// let example =
///   driver.new()
///   |> driver.wait(2000)
///   |> driver.goto("https://gleam.run/")
/// ```
///
pub fn wait(state: state, duration: Int) -> state {
  process.sleep(duration)
  state
}

///
/// Closes the webdriver session, closes the browser, and returns the value of the last function called
/// 
/// # Example
///
/// This example closes the webdriver session, and returns "gleam", the inner text of the element with the css selector `a.logo`:
///
/// ```gleam
/// let example = driver.new()
///   |> driver.goto("https://gleam.run/")
///   |> query.node(by.css("a.logo"))
///   |> nodes.inner_text()
///   |> driver.close()
/// ```
///
pub fn close(driver_with_state: #(WebDriver, state)) -> state {
  let #(driver, state) = driver_with_state

  browser.close(driver.socket)
  socket.close(driver.socket)

  state
}
