import butterbee/browser.{type Browser}
import butterbee/config
import butterbee/internal/error
import butterbee/internal/runner/chromium
import butterbee/internal/runner/firefox
import gleam/dict
import gleam/erlang/process
import gleam/list
import gleam/option
import gleam/result
import gleam/string
import operating_system
import palabres as logger
import shellout
import simplifile

/// Start a browser instance
pub fn new(
  browser_to_run: config.BrowserType,
  config: config.ButterbeeConfig,
) -> Result(Browser, error.ButterbeeError) {
  let driver_config = config.driver
  let config =
    config.browser_config
    |> option.unwrap(config.default_browser_config())
    |> dict.get(browser_to_run)
    |> result.unwrap(config.default_individual_browser_config(config.Firefox))

  use request <- result.try({
    browser.new_port()
    |> result.map(fn(port) { browser.get_request(port, config.host) })
    |> result.map_error(error.PortError)
  })

  use #(profile, profile_dir) <- result.try({
    browser.new_profile(driver_config.data_dir)
    |> result.map_error(error.CreateProfileDirError)
  })

  let flags = case browser_to_run {
    config.Firefox ->
      firefox.get_flags(
        { [config.start_url] |> list.append(config.extra_flags) },
        request.port,
        profile_dir,
      )
    config.Chromium ->
      chromium.get_flags(
        { [config.start_url] |> list.append(config.extra_flags) },
        request.port,
      )
  }

  use _ <- result.try({
    case browser_to_run {
      config.Firefox -> firefox.setup(profile_dir)
      config.Chromium -> chromium.setup()
    }
  })

  let browser =
    browser.new(browser_to_run)
    |> browser.with_request(request)
    |> browser.with_profile_dir(profile_dir)
    |> browser.with_profile_name(profile)
    |> browser.with_cmd(#(config.cmd, flags))

  use browser <- result.try({
    run(browser) |> result.map_error(fn(_) { error.RunnerError })
  })

  Ok(browser)
}

/// Run the browser
/// TODO: Should maybe be a shell script for better lifetime management
fn run(browser: Browser) -> Result(Browser, error.ButterbeeError) {
  use #(cmd, flags) <- result.try({
    browser.cmd
    |> option.to_result(error.BrowserDoesNotHaveCmd)
  })

  use profile_dir <- result.try({
    browser.profile_dir
    |> option.to_result(error.BrowserDoesNotHaveProfileDir)
  })

  logger.info("Starting browser")
  |> logger.string("cmd", cmd)
  |> logger.string("flags", string.inspect(flags))
  |> logger.string("profile_dir", profile_dir)
  |> logger.log

  do_run(cmd, flags, profile_dir)

  Ok(browser)
}

fn do_run(cmd: String, flags: List(String), profile_dir: String) {
  process.spawn(fn() {
    let browser = list.prepend(flags, cmd)
    let wrapper_cmd = case operating_system.name() {
      "linux" | "darwin" -> "runner.sh"
      "windows_nt" -> "runner.ps1"
      _ -> {
        logger.error("Unsupported operating system")
        |> logger.string("error", operating_system.name())
        |> logger.log
        "runner.sh"
      }
    }
    let _ = case
      shellout.command(
        run: "src/butterbee/internal/runner/" <> wrapper_cmd,
        with: browser,
        in: ".",
        opt: [],
      )
    {
      Ok(_) -> Nil
      Error(error) -> {
        logger.error("Error running browser command")
        |> logger.string("error", error.1)
        |> logger.log
      }
    }

    // INFO: This run after the browser  closes
    logger.debug("Cleaning up profile directory")
    |> logger.log
    let _ = case simplifile.delete(profile_dir) {
      Ok(_) -> Ok(Nil)
      Error(error) -> Error(error.CouldNotDeleteProfileDir(error))
    }

    option.Some("Done")
  })
}
