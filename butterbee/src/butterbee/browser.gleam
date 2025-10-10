//// 
//// The browser module contains the Browser type and functions to create and configure browsers.
////
//// Usually you will not need to use this module directly, as it is usually derived
//// from the configuration in the butterbee.toml file.
////

import butterbee/config/browser as browser_config
import butterbee/internal/error
import butterbee/internal/retry
import butterlib/log
import gleam/http.{Http}
import gleam/http/request.{type Request}
import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import simplifile
import youid/uuid

///
/// The Browser type contains all the information needed to run a browser.
///
pub type Browser {
  Browser(
    /// The type of browser to run.
    browser_type: browser_config.BrowserType,
    /// The command to run the browser including the flags.
    cmd: Option(#(String, List(String))),
    /// The url to use to start the browser.
    request: Option(Request(String)),
    /// The name of the profile to use for the browser.
    profile_name: Option(String),
    /// The directory where the profile is located.
    profile_dir: Option(String),
  )
}

pub fn default() -> Browser {
  Browser(
    browser_type: browser_config.default_browser_type(),
    cmd: None,
    request: None,
    profile_name: None,
    profile_dir: None,
  )
}

pub fn new(browser_to_run: browser_config.BrowserType) -> Browser {
  Browser(
    browser_type: browser_to_run,
    cmd: None,
    request: None,
    profile_name: None,
    profile_dir: None,
  )
}

pub fn with_cmd(browser: Browser, cmd: #(String, List(String))) -> Browser {
  Browser(..browser, cmd: Some(cmd))
}

pub fn with_request(browser: Browser, request: Request(String)) -> Browser {
  Browser(..browser, request: Some(request))
}

pub fn with_profile_name(browser: Browser, profile_name: String) -> Browser {
  Browser(..browser, profile_name: Some(profile_name))
}

pub fn with_profile_dir(browser: Browser, profile_dir: String) -> Browser {
  Browser(..browser, profile_dir: Some(profile_dir))
}

pub fn get_request(port: Int, host: String) -> Request(String) {
  request.new()
  |> request.set_host(host)
  |> request.set_port(port)
  |> request.set_path("/session")
  |> request.set_scheme(Http)
}

///
/// Returns the port to use for the browser
///
pub fn new_port(
  data_dir: String,
  browser_config: browser_config.BrowserConfig,
) -> Result(Int, error.ButterbeeError) {
  let port_dir = data_dir <> "/used_ports"

  let #(min, max) = browser_config.port_range

  use _ <- result.try({
    simplifile.create_directory_all(port_dir)
    |> result.map_error(error.CreatePortDirError)
  })

  // Get a a list of used ports
  use ports <- result.try(
    {
      // Read the files in the port directory
      simplifile.read_directory(port_dir)
      |> result.map_error(error.ReadPortDirError)
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
      log.debug("Checking if port: " <> int.to_string(port) <> " is open")
      case !list.contains(ports, port) {
        True ->
          log.debug_and_continue(
            "Open port found: " <> int.to_string(port),
            True,
          )
        False -> False
      }
    })

  use _ <- result.try({
    simplifile.create_file(port_dir <> "/" <> int.to_string(port))
    |> result.map_error(error.FileError)
  })

  Ok(port)
}

///
/// Create a new profile directory
/// Returns the name of the profile
///
pub fn new_profile(
  data_dir: String,
) -> Result(#(String, String), simplifile.FileError) {
  let profile = uuid.v7() |> uuid.to_string()
  let profile_dir = data_dir <> "/" <> profile

  let profile =
    simplifile.create_directory_all(profile_dir)
    |> result.map(with: fn(_) { #(profile, profile_dir) })

  log.debug("Created profile at " <> profile_dir)

  profile
}
