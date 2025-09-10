import butterbee/internal/browser.{type Browser, Browser}
import butterbee/internal/config/browser_config
import butterbee/internal/config/config
import butterbee/internal/retry
import butterbee/internal/runner/errors
import butterbee/internal/runner/firefox
import butterbee/internal/runner/runnable.{type Runnable}
import gleam/dict
import gleam/erlang/process
import gleam/int
import gleam/list
import gleam/option.{None, Some}
import gleam/result
import gleam/string
import logging
import shellout
import simplifile

pub fn new(config: config.ButterbeeConfig) -> Result(Browser, errors.Error) {
  let browser_config =
    config.browser_config
    |> option.unwrap(browser_config.default())
    |> dict.get(config.driver_config.browser)
    |> result.unwrap(browser_config.default_configuration())

  use port <- result.try({
    get_port(config.driver_config.data_dir, browser_config)
  })

  let browser =
    browser.from_config(config.driver_config.browser, browser_config)
    |> browser.with_extra_flags(browser_config.extra_flags)
    |> browser.with_port(port)

  let request = browser.get_request(port, browser)

  // update browser with request
  let browser = browser |> browser.with_request(request)

  use _ <- result.try({
    use runnable <- result.try(case browser.browser_type {
      browser_config.Firefox -> firefox.setup(browser, config)
      browser_config.Chrome -> todo
    })

    run(runnable) |> result.map_error(errors.RunnerError)
  })

  Ok(browser)
}

pub fn get_port(
  data_dir: String,
  browser_config: browser_config.BrowserConfig,
) -> Result(Int, errors.Error) {
  let port_dir = data_dir <> "/used_ports"

  let #(min, max) = browser_config.port_range

  use _ <- result.try({
    simplifile.create_directory_all(port_dir)
    |> result.map_error(errors.CreatePortDirError)
  })

  // Get a a list of used ports
  use ports <- result.try(
    {
      // Read the files in the port directory
      simplifile.read_directory(port_dir)
      |> result.map_error(errors.ReadPortDirError)
    }
    // Convert the list of port strings to a list of port ints
    |> result.map(fn(files) {
      files
      |> list.map(fn(file) {
        int.parse(file)
        |> result.unwrap(browser_config.default_port)
      })
    }),
  )

  let max_list_size = case max - min {
    a if a <= 0 -> panic as "max port range must be greater than min port range"
    _ -> max - min
  }

  let _ = case list.length(ports) {
    s if s >= max_list_size -> panic as "Not enough ports open"
    _ -> True
  }

  let port =
    retry.incremented(min, fn(port) {
      logging.log(
        logging.Debug,
        "Checking if port: " <> int.to_string(port) <> " is open",
      )
      case !list.contains(ports, port) {
        True -> {
          logging.log(logging.Debug, "Open port found: " <> int.to_string(port))
          True
        }
        False -> False
      }
    })

  use _ <- result.try({
    simplifile.create_file(port_dir <> "/" <> int.to_string(port))
    |> result.map_error(errors.FileError)
  })

  Ok(port)
}

fn run(runnable: Runnable) -> Result(Runnable, errors.Error) {
  let #(cmd, flags) = runnable.cmd

  logging.log(
    logging.Debug,
    "Starting " <> cmd <> " with flags: " <> string.inspect(flags),
  )

  process.spawn(fn() {
    let _ = case
      shellout.command(run: cmd, with: flags, in: runnable.profile_dir, opt: [
        //shellout.LetBeStdout,
      ])
    {
      Ok(_) -> Nil
      Error(error) -> {
        let #(_, error) = error
        logging.log(logging.Error, "Error running browser command: " <> error)
      }
    }
    logging.log(logging.Debug, "Cleaning up profile directory")
    let assert Ok(_) = simplifile.delete(runnable.profile_dir)
      as "Failed to delete profile directory"

    // Wait a bit before deleting the port file
    process.sleep(1000)

    let port = "/tmp/butterbee/used_ports/" <> runnable.port
    logging.log(logging.Debug, "Deleting port file at " <> runnable.port)
    let assert Ok(_) = simplifile.delete(port) as "Failed to delete port file"
    Nil
  })

  Ok(runnable)
}
