//// The browser module contains the Browser type, which holds the state and configuration
//// of the browser session.

import butterbee/config
import butterbee/internal/error
import butterbee/internal/id
import gleam/http.{Http}
import gleam/http/request.{type Request}
import gleam/int
import gleam/option.{type Option, None, Some}
import gleam/result
import palabres as log
import simplifile

/// The Browser type contains all the information needed to run a browser.
pub type Browser {
  Browser(
    /// The type of browser to run.
    browser_type: config.BrowserType,
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

pub const default: Browser = Browser(
  browser_type: config.default_browser_type,
  cmd: None,
  request: None,
  profile_name: None,
  profile_dir: None,
)

pub fn new(browser_to_run: config.BrowserType) -> Browser {
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

/// Returns a free port to use for a webdriver session
@external(erlang, "browser_ffi", "new_port")
pub fn new_port() -> Result(Int, error.PortError)

/// Create a new profile directory
/// Returns the name of the profile
pub fn new_profile(
  data_dir: String,
) -> Result(#(String, String), simplifile.FileError) {
  let profile_name = int.to_string(id.from_unix())
  let profile_dir = data_dir <> "/" <> profile_name

  let profile =
    simplifile.create_directory_all(profile_dir)
    |> result.map(with: fn(_) { #(profile_name, profile_dir) })

  log.debug("Creating profile")
  |> log.string("profile dir", profile_dir)
  |> log.string("profile name", profile_name)
  |> log.log

  profile
}
