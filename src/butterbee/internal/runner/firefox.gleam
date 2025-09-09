import butterbee/internal/browser
import butterbee/internal/config/browser_config
import butterbee/internal/config/config
import butterbee/internal/runner/errors
import butterbee/internal/runner/runnable
import gleam/int
import gleam/list
import gleam/option
import gleam/result
import logging
import simplifile
import youid/uuid

const default_flags = [
  "-wait-for-browser", "-no-first-run", "-no-default-browser-check",
  "-no-remote",
]

pub fn setup(browser: browser.Browser, config: config.ButterbeeConfig) {
  use #(profile, profile_dir) <- result.try({
    create_profile_dir(config.driver_config.data_dir)
    |> result.map_error(errors.CreateProfileDirError)
  })

  let port =
    browser.port
    |> option.unwrap(browser_config.default_port)
    |> int.to_string()

  logging.log(
    logging.Debug,
    "creating profile: " <> profile <> " in " <> profile_dir,
  )

  let flags =
    default_flags
    |> list.append(["-remote-debugging-port=" <> port, "-profile " <> profile])
    |> list.append(browser.extra_flags |> option.unwrap(default_flags))

  let runnable =
    runnable.new(browser_config.Firefox)
    |> runnable.with_cmd(#("firefox", flags))
    |> runnable.with_port(port)
    |> runnable.with_profile(profile)
    |> runnable.with_profile_dir(profile_dir)

  Ok(runnable)
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
