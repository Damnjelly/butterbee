import butterbee/config
import butterbee/internal/commands/browser
import butterbee/internal/commands/browsing_context
import butterbee/internal/commands/session
import butterbee/internal/error
import butterbee/internal/log
import butterbee/internal/retry
import butterbee/internal/runner/runner
import butterbee/internal/socket
import butterbee/webdriver.{type WebDriver}
import butterbidi/browsing_context/commands/get_tree
import butterbidi/browsing_context/commands/navigate
import butterbidi/browsing_context/types/info.{type Info}
import butterbidi/browsing_context/types/readiness_state
import exception
import gleam/erlang/process
import gleam/list
import gleam/option.{None, Some}
import gleam/result
import gleam/string
import gleam/uri
import palabres as logger
import simplifile

/// Initialize butterbee,
/// Call this in the main function of your test, before calling gleeunit.main.
/// Then call [`butterbee.run`](file:///home/gelei/Documents/butterbee/butterbee/build/dev/docs/butterbee/butterbee.html#run) in your test
/// to start using butterbee.
///
/// Note: Adds a log filter for `WebSocket handshake failed: Sock(Econnrefused)`
pub fn init() {
  logger.debug("Initializing butterbee")
  |> logger.log

  logger.debug("Deleting data_dir")
  |> logger.log
  let _ = simplifile.delete("/tmp/butterbee")

  log.add_primary_filters(log.filters)
  Nil
}

/// Start a new webdriver session connect to the browser session, 
/// using the configuration in the gleam.toml file.
///  WebDriver holds the browsing context info in its state
pub fn run(
  browsers: List(config.BrowserType),
  run: fn(WebDriver(Info)) -> a,
) -> Nil {
  let config = case config.parse_config("gleam.toml") {
    Ok(config) -> config
    Error(error) -> {
      logger.info("could not parse gleam.toml")
      |> logger.string("error", string.inspect(error))
      |> logger.log
      config.default_config
    }
  }

  run_with_config(browsers, config, run)
}

/// Start a new webdriver session connect to the browser session, using the ButterbeeConfig type
pub fn run_with_config(
  browsers: List(config.BrowserType),
  config: config.ButterbeeConfig,
  run: fn(WebDriver(Info)) -> a,
) -> Nil {
  use browser_type <- list.each(browsers)

  // Create webdriver type
  let driver =
    webdriver.new()
    |> webdriver.with_config(config)

  let session = case driver.config {
    None -> Error(error.DriverDoesNotHaveConfig)
    Some(config) -> {
      logger.info("Starting browser")
      |> logger.string("browser", config.browser_type_to_string(browser_type))
      |> logger.log
      use browser <- result.try({ runner.new(browser_type, config) })

      logger.debug("Getting capabilities")
      |> logger.log

      let capabilities =
        config.capabilities
        |> option.unwrap(config.default_capabilities_config())

      logger.debug("Getting request")
      |> logger.log

      use request <- result.try({
        browser.request
        |> option.to_result(error.BrowserDoesNotHaveRequest)
      })

      logger.debug("Checking if browser is ready")
      |> logger.log

      use _ <- result.try(retry.until_ok(fn() { session.status(request) }))

      logger.debug("Starting webdriver session")
      |> logger.log

      session.new(request, capabilities)
    }
  }

  let driver = case session {
    Error(error) -> {
      logger.error("Failed to create webdriver session")
      |> logger.string("error", string.inspect(error))
      |> logger.log
      webdriver.with_state(driver, Error(error))
    }
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

  use <- exception.defer(fn() { close(driver) })

  logger.info("Starting test")
  |> logger.log
  run(driver)
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
@internal
pub fn close(driver: WebDriver(state)) {
  logger.info("Closing webdriver session")
  |> logger.log
  let _ = browser.close(driver)
  use socket <- result.try({ webdriver.get_socket(driver) })
  let _ = socket.close(socket)
  driver.state
}

/// Returns the state of the test without closing the webdriver session 
pub fn value(driver: WebDriver(state)) {
  driver.state
}
