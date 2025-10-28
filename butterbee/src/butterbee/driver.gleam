//// The driver module contains functions for interacting with the webdriver client 

import butterbee/commands/browser
import butterbee/commands/browsing_context
import butterbee/commands/session
import butterbee/config
import butterbee/config/browser as browser_config
import butterbee/config/capabilities as capabilities_config
import butterbee/internal/error
import butterbee/internal/retry
import butterbee/internal/runner/runner
import butterbee/internal/socket
import butterbee/webdriver.{type WebDriver}
import butterbidi/browsing_context/commands/get_tree
import butterbidi/browsing_context/commands/navigate
import butterbidi/browsing_context/types/browsing_context as _
import butterbidi/browsing_context/types/info
import butterbidi/browsing_context/types/readiness_state
import butterlib/log
import gleam/erlang/process
import gleam/list
import gleam/option.{None, Some}
import gleam/result
import gleam/string
import gleam/uri

/// Start a new webdriver session connect to the browser session, 
/// using the configuration in the gleam.toml file.
///  WebDriver holds the browsing context info in its state
pub fn new(browser: browser_config.BrowserType) {
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

/// Start a new webdriver session connect to the browser session, using the ButterbeeConfig type
pub fn new_with_config(
  browser_type: browser_config.BrowserType,
  config: config.ButterbeeConfig,
) -> WebDriver(info.Info) {
  log.debug(
    "Starting webdriver session with config: " <> string.inspect(config),
  )
  // Create webdriver type
  let driver =
    webdriver.new()
    |> webdriver.with_config(config)

  let session = case driver.config {
    None -> Error(error.DriverDoesNotHaveConfig)
    Some(config) -> {
      // Start browser
      use browser <- result.try({ runner.new(browser_type, config) })

      let capabilities =
        config.capabilities
        |> option.unwrap(capabilities_config.default)

      use request <- result.try({
        browser.request
        |> option.to_result(error.BrowserDoesNotHaveRequest)
      })

      // Check if browser is ready
      use _ <- result.try({ retry.until_ok(fn() { session.status(request) }) })

      // Start webdriver session
      session.new(request, capabilities)
    }
  }

  case session {
    Error(error) -> webdriver.with_state(driver, Error(error))
    Ok(new) -> {
      let #(socket, session) = new

      let driver =
        driver
        |> webdriver.with_socket(socket)
        |> webdriver.with_state(Ok(session))

      // Get initial browsing context
      let get_tree_parameters =
        get_tree.default
        |> get_tree.with_max_depth(1)

      let get_tree =
        retry.until_ok(fn() {
          browsing_context.get_tree(driver, get_tree_parameters)
        })

      let info = case get_tree {
        Error(error) -> Error(error)
        Ok(get_tree) -> {
          case get_tree.contexts.list {
            [info] -> Ok(info)
            _ -> Error(error.NoBrowsingContexts)
          }
        }
      }

      case info {
        Ok(info) ->
          webdriver.with_context(driver, info.context)
          |> webdriver.with_state(Ok(info))
        Error(error) -> webdriver.with_state(driver, Error(error))
      }
    }
  }
}

/// Navigates to the given url
pub fn goto(
  driver: WebDriver(state),
  url: String,
) -> WebDriver(navigate.NavigateResult) {
  let result = case uri.parse(url) {
    Error(Nil) -> Error(error.CouldNotParseUrl(url))
    Ok(uri) -> {
      let driver =
        driver
        |> webdriver.with_state(Ok(uri))

      case driver.state {
        Error(error) -> Error(error)
        Ok(uri) -> {
          let url = uri.to_string(uri)
          use context <- result.try({ webdriver.get_context(driver) })
          let params =
            navigate.default(context, url)
            |> navigate.with_wait(readiness_state.Interactive)

          browsing_context.navigate(driver, params)
        }
      }
    }
  }

  driver
  |> webdriver.with_state(result)
}

/// Returns the url of the current page
pub fn url(driver: WebDriver(state)) -> WebDriver(String) {
  case browsing_context.get_tree(driver, get_tree.default) {
    Error(error) -> Error(error)
    Ok(get_tree_result) -> {
      list.first(get_tree_result.contexts.list)
      |> result.map_error(fn(_) { error.NoInfoFound })
      |> result.map(fn(context) { context.url })
    }
  }
  |> webdriver.map_state(driver)
}

/// Pause for a given amount of time (in milliseconds) before continuing
pub fn wait(state: state, duration: Int) -> state {
  process.sleep(duration)
  state
}

/// Closes the webdriver session, closes the browser, and returns the state of the webdriver
pub fn close(driver: WebDriver(state)) {
  let _ = browser.close(driver)
  use socket <- result.try({ webdriver.get_socket(driver) })
  socket.close(socket)
  driver.state
}

/// Returns the state of the test without closing the webdriver session 
pub fn value(driver: WebDriver(state)) {
  driver.state
}
