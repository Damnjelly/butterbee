////
//// The driver module contains functions for interacting with the webdriver client 
////

import butterbee/commands/browser
import butterbee/commands/browsing_context
import butterbee/commands/session
import butterbee/config
import butterbee/config/browser as browser_config
import butterbee/config/capabilities as capabilities_config
import butterbee/internal/retry
import butterbee/internal/runner/runner
import butterbee/internal/socket
import butterbee/webdriver.{type WebDriver}
import butterbidi/browsing_context/commands/get_tree
import butterbidi/browsing_context/commands/navigate
import butterbidi/browsing_context/types/browsing_context as _
import butterbidi/browsing_context/types/info
import butterbidi/browsing_context/types/readiness_state
import butterbidi/definition
import butterlib/log
import gleam/erlang/process
import gleam/list
import gleam/option.{Some}
import gleam/result
import gleam/string
import gleam/uri

///
/// Start a new webdriver session connect to the browser session, 
/// using the configuration in the gleam.toml file.
///  WebDriver holds the browsing context info in its state
/// 
pub fn new(browser: browser_config.BrowserType) -> WebDriver(info.InfoList) {
  let config = case config.parse_config("gleam.toml") {
    Ok(config) -> config
    Error(error) ->
      log.error_and_continue(
        "Failed to parse gleam.toml: " <> string.inspect(error),
        config.default,
      )
  }

  new_with_config(browser, config)
}

///
/// Start a new webdriver session connect to the browser session, using the ButterbeeConfig type
///
pub fn new_with_config(
  browser: browser_config.BrowserType,
  config: config.ButterbeeConfig,
) -> WebDriver(info.InfoList) {
  log.debug(
    "Starting webdriver session with config: " <> string.inspect(config),
  )
  let driver =
    webdriver.new()
    |> webdriver.with_config(config)

  // Start browser
  let assert Ok(browser) = runner.new(browser, config)

  let capabilities =
    config.capabilities
    |> option.unwrap(capabilities_config.default)

  let assert Some(request) = browser.request

  // Check if browser is ready
  let assert Ok(_) = retry.until_ok(fn() { session.status(request) })

  // Start webdriver session
  let #(socket, session) = session.new(request, capabilities)

  let driver =
    driver
    |> webdriver.with_socket(socket)

  let assert Ok(_response) = session

  // Get initial browsing context
  let get_tree_parameters =
    get_tree.default
    |> get_tree.with_max_depth(1)

  let result =
    retry.until_ok(fn() {
      browsing_context.get_tree(driver, get_tree_parameters)
    })
    |> result.map(fn(get_tree_result) { get_tree_result.contexts })

  let assert Ok(info_list) = result

  let context = case list.length(info_list.list) {
    1 -> {
      let assert Ok(info) = list.first(info_list.list)
        as "Found no browsing contexts"
      info.context
    }
    _ -> panic as "Found more than one, or zero, browsing contexts"
  }

  driver
  |> webdriver.with_state(result)
  |> webdriver.with_context(context)
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
pub fn goto(
  driver: WebDriver(state),
  url: String,
) -> WebDriver(navigate.NavigateResult) {
  let err = "Could not parse url: " <> url
  let assert Ok(uri) = uri.parse(url) as err

  let driver =
    driver
    |> webdriver.with_state(Ok(uri))

  let url =
    webdriver.assert_state(driver)
    |> uri.to_string()

  let params =
    navigate.default(webdriver.get_context(driver), url)
    |> navigate.with_wait(readiness_state.Interactive)

  browsing_context.navigate(driver, params)
  |> webdriver.map_state(driver)
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
pub fn wait(state: s, duration: Int) -> s {
  process.sleep(duration)
  state
}

///
/// Closes the webdriver session, closes the browser, and returns the state of the webdriver
/// 
/// # Example
///
/// This example closes the webdriver session, and returns "Gleam",
/// the inner text of the element with the css selector `a.logo`:
///
/// ```gleam
/// let example = driver.new()
///   |> driver.goto("https://gleam.run/")
///   |> query.node(by.css("a.logo"))
///   |> nodes.inner_text()
///   |> driver.close()
/// ```
///
pub fn close(
  driver: WebDriver(state),
) -> Result(state, definition.ErrorResponse) {
  browser.close(driver)
  socket.close(webdriver.get_socket(driver))

  driver.state
}

///
/// Returns the state of the test without closing the webdriver session 
/// 
/// # Example
///
/// This example returns "Gleam" without closing the session:
///
/// ```gleam
/// let example = driver.new()
///   |> driver.goto("https://gleam.run/")
///   |> query.node(by.css("a.logo"))
///   |> nodes.inner_text()
///   |> driver.value()
/// ```
///
pub fn value(
  driver: WebDriver(state),
) -> Result(state, definition.ErrorResponse) {
  driver.state
}
