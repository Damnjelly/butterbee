import butterbee/internal/browser.{type Browser, Browser}
import butterbee/internal/config
import butterbee/internal/retry
import gleam/erlang/process
import gleam/http/request.{type Request}
import gleam/int
import gleam/list
import gleam/option.{None, Some}
import gleam/result
import gleam/string
import logging
import shellout
import simplifile
import youid/uuid

pub fn start(config: config.DriverConfig) -> Result(Request(String), String) {
  let assert Ok(#(profile, profile_dir)) = create_profile_dir("/tmp/butterbee")
    as "Failed to create profile directory"

  use request <- result.try({
    let browser =
      config.browser
      |> option.unwrap(browser.default())

    start_browser(
      config,
      Browser(
        ..browser,
        profile_dir: Some(profile_dir),
        profile_name: Some(profile),
      ),
    )
  })

  Ok(request)
}

/// Create a new profile directory
/// Returns the name of the profile
fn create_profile_dir(
  data_dir: String,
) -> Result(#(String, String), simplifile.FileError) {
  let profile = uuid.v7() |> uuid.to_string()
  let profile_dir = data_dir <> "/" <> profile

  simplifile.create_directory_all(profile_dir)
  |> result.map(with: fn(_) { #(profile, profile_dir) })
}

pub fn get_port(port_range: #(Int, Int), data_dir: String) -> Int {
  let port_dir = data_dir <> "/used_ports"
  let #(min, max) = port_range

  let assert Ok(_) = simplifile.create_directory_all(port_dir)
    as "Failed to create port directory"

  let ports =
    simplifile.read_directory(port_dir)
    |> result.unwrap([])
    |> list.map(fn(file) {
      int.parse(file)
      |> result.unwrap(9222)
    })

  let max_list_size = case max - min {
    a if a <= 0 -> panic as "max port range must be greater than min port range"
    _ -> max - min
  }

  let port =
    retry.incremented(min, fn(port) {
      logging.log(
        logging.Debug,
        "Checking if port is open: " <> int.to_string(port),
      )
      let _ = case list.length(ports) {
        s if s >= max_list_size -> panic as "Not enough ports open"
        _ -> True
      }
      case !list.contains(ports, port) {
        True -> {
          logging.log(logging.Debug, "Open port found: " <> int.to_string(port))
          True
        }
        False -> False
      }
    })

  let assert Ok(_) =
    simplifile.create_file(port_dir <> "/" <> int.to_string(port))
    as "Failed to create port file"

  port
}

fn start_browser(
  config: config.DriverConfig,
  browser: Browser,
) -> Result(Request(String), String) {
  let port = get_port(browser.port_range, config.data_dir)

  let request = browser.get_request(port, browser)

  let port = port |> int.to_string()

  let assert Some(profile) = browser.profile_name as "Profile name not set"

  let assert Some(profile_dir) = browser.profile_dir
    as "Profile directory not set"

  let #(cmd, flags) = case browser.browser_type {
    browser.Firefox -> {
      logging.log(
        logging.Debug,
        "creating profile: " <> profile <> " in " <> profile_dir,
      )

      #("firefox", [
        "-remote-debugging-port=" <> port,
        "-wait-for-browser",
        "-no-first-run",
        "-no-default-browser-check",
        "-no-remote",
        // "-headless",
        "-profile " <> profile,
      ])
    }
    browser.Chrome -> todo
  }

  logging.log(
    logging.Debug,
    "Starting " <> cmd <> " with flags: " <> string.inspect(flags),
  )

  process.spawn(fn() {
    let _ = case
      shellout.command(run: cmd, with: flags, in: profile_dir, opt: [
        shellout.LetBeStdout,
      ])
    {
      Ok(_) -> Nil
      Error(error) -> {
        let #(_, error) = error
        logging.log(logging.Error, "Error running browser command: " <> error)
      }
    }
    logging.log(logging.Debug, "Cleaning up profile directory")
    let assert Ok(_) = simplifile.delete(profile_dir)
      as "Failed to delete profile directory"

    // Wait a bit before deleting the port file
    process.sleep(1000)

    let port = "/tmp/butterbee/used_ports/" <> port
    logging.log(logging.Debug, "Deleting port file at " <> port)
    let assert Ok(_) = simplifile.delete(port) as "Failed to delete port file"
    Nil
  })

  Ok(request)
}
