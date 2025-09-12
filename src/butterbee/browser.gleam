import butterbee/config/browser_config
import gleam/http.{Http}
import gleam/http/request.{type Request}
import gleam/option.{type Option, None, Some}

pub type Browser {
  Browser(
    browser_type: browser_config.BrowserType,
    host: String,
    port_range: #(Int, Int),
    port: Option(Int),
    extra_flags: Option(List(String)),
    request: Option(Request(String)),
  )
}

// Browser Builders

pub fn default() -> Browser {
  Browser(
    browser_type: browser_config.default_browser_type(),
    host: browser_config.default_host,
    port_range: browser_config.default_port_range,
    extra_flags: None,
    request: None,
    port: None,
  )
}

pub fn from_config(
  browser_to_run: browser_config.BrowserType,
  browser_config: browser_config.BrowserConfig,
) -> Browser {
  Browser(
    browser_type: browser_to_run,
    host: browser_config.host,
    port_range: browser_config.port_range,
    extra_flags: Some(browser_config.extra_flags),
    request: None,
    port: None,
  )
}

pub fn with_extra_flags(browser: Browser, extra_flags: List(String)) -> Browser {
  Browser(..browser, extra_flags: Some(extra_flags))
}

pub fn with_request(browser: Browser, request: Request(String)) -> Browser {
  Browser(..browser, request: Some(request))
}

pub fn with_port(browser: Browser, port: Int) -> Browser {
  Browser(..browser, port: Some(port))
}

pub fn get_request(port: Int, browser: Browser) -> Request(String) {
  request.new()
  |> request.set_host(browser.host)
  |> request.set_port(port)
  |> request.set_path("/session")
  |> request.set_scheme(Http)
}
