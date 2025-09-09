import gleam/dynamic.{type Dynamic}
import gleam/dynamic/decode
import gleam/http.{Http}
import gleam/http/request.{type Request}
import gleam/list
import gleam/option.{type Option, None}

pub const default_host = "127.0.0.1"

pub const default_port_range = #(9222, 9232)

pub type Browser {
  Browser(
    host: String,
    port_range: #(Int, Int),
    port: Option(Int),
    profile_dir: Option(String),
    profile_name: Option(String),
    browser_type: BrowserType,
    extra_flags: Option(List(String)),
  )
}

pub type BrowserType {
  Firefox
  Chrome
}

pub fn browser_type_decoder() -> decode.Decoder(BrowserType) {
  use browser_type <- decode.then(decode.string)
  case browser_type {
    "firefox" -> decode.success(Firefox)
    "chrome" -> decode.success(Chrome)
    _ -> decode.failure(Firefox, "Browser type not supported: " <> browser_type)
  }
}

pub fn default() -> Browser {
  Browser(
    host: default_host,
    port_range: default_port_range,
    port: None,
    profile_dir: None,
    profile_name: None,
    browser_type: Firefox,
    extra_flags: None,
  )
}

pub fn get_request(port: Int, browser: Browser) -> Request(String) {
  // TODO: randomize/increment ports

  request.new()
  |> request.set_host(browser.host)
  |> request.set_port(port)
  |> request.set_path("/session")
  |> request.set_scheme(Http)
}
