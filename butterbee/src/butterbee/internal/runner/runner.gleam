import butterbee/browser.{type Browser}
import butterbee/config
import butterbee/config/browser as browser_config
import butterbee/internal/error
import butterbee/internal/runner/firefox
import butterlib/log
import gleam/dict
import gleam/erlang/process
import gleam/list
import gleam/option.{Some}
import gleam/result
import gleam/string
import shellout
import simplifile

///
/// Start a browser instance
///
pub fn new(
  browser_to_run: browser_config.BrowserType,
  config: config.ButterbeeConfig,
) -> Result(Browser, error.ButterbeeError) {
  let driver_config = config.driver
  let browser_config =
    config.browser_config
    |> option.unwrap(browser_config.default())
    |> dict.get(browser_to_run)
    |> result.unwrap(browser_config.default_configuration)

  use request <- result.try({
    browser.new_port(driver_config.data_dir, browser_config)
    |> result.map(fn(port) { browser.get_request(port, browser_config.host) })
  })

  use #(profile, profile_dir) <- result.try({
    browser.new_profile(driver_config.data_dir)
    |> result.map_error(error.CreateProfileDirError)
  })

  let flags = case browser_to_run {
    browser_config.Firefox ->
      firefox.get_flags(browser_config.extra_flags, request.port, profile_dir)
    // browser_config.Chrome -> todo as "Chrome not supported yet"
  }

  use _ <- result.try({
    case browser_to_run {
      browser_config.Firefox -> firefox.setup(profile_dir)
      // browser_config.Chrome -> todo as "Chrome not supported yet"
    }
  })

  let browser =
    browser.new(browser_to_run)
    |> browser.with_request(request)
    |> browser.with_profile_dir(profile_dir)
    |> browser.with_profile_name(profile)
    |> browser.with_cmd(#(browser_config.cmd, flags))

  use browser <- result.try({
    run(browser) |> result.map_error(fn(_) { error.RunnerError })
  })

  Ok(browser)
}

///
/// Run the browser
/// TODO: Should maybe be a shell script for better lifetime management
///
fn run(browser: Browser) -> Result(Browser, error.ButterbeeError) {
  let assert Some(#(cmd, flags)) = browser.cmd

  let assert Some(profile_dir) = browser.profile_dir

  log.info("Starting " <> cmd <> " with flags: " <> string.inspect(flags))

  process.spawn(fn() {
    let _ = case
      shellout.command(run: cmd, with: flags, in: profile_dir, opt: [])
    {
      Ok(_) -> Nil
      Error(error) -> log.error("Error running browser command: " <> error.1)
    }

    // INFO: This run after the browser  closes
    log.debug("Cleaning up profile directory")
    let assert Ok(_) = simplifile.delete(profile_dir)
      as "Failed to delete profile directory"
    Some("Done")
  })

  Ok(browser)
}
