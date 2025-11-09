import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}

/// Butterbee will use this command unless overridden
pub const default_cmd = "chromedriver"

/// Butterbee will use this start url unless overridden
pub const default_start_url = "about:blank"

const default_flags = []

/// Returns the flags firefox needs to run
pub fn get_flags(flags: List(String), port: Option(Int)) -> List(String) {
  let remote_debugging_port = case port {
    None -> []
    Some(port) -> ["--port=" <> int.to_string(port)]
  }
  flags
  |> list.append(default_flags)
  |> list.append(remote_debugging_port)
}

/// Create a session using chromedriver
pub fn setup() {
  Ok(Nil)
}
