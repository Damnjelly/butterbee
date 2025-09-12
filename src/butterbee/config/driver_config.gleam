import butterbee/config/browser_config
import gleam/dynamic/decode

const default_max_wait_time = 20_000

const default_request_timeout = 5000

const default_data_dir = "/tmp/butterbee"

pub type DriverConfig {
  DriverConfig(
    browser: browser_config.BrowserType,
    max_wait_time: Int,
    request_timeout: Int,
    data_dir: String,
  )
}

pub fn driver_config_decoder() -> decode.Decoder(DriverConfig) {
  use browser <- decode.optional_field(
    "browser",
    browser_config.default_browser_type(),
    browser_config.browser_type_decoder(),
  )
  use max_wait_time <- decode.optional_field(
    "max_wait_time",
    default_max_wait_time,
    decode.int,
  )
  use request_timeout <- decode.optional_field(
    "request_timeout",
    default_request_timeout,
    decode.int,
  )
  use data_dir <- decode.optional_field(
    "data_dir",
    default_data_dir,
    decode.string,
  )

  decode.success(DriverConfig(
    browser:,
    max_wait_time:,
    request_timeout:,
    data_dir:,
  ))
}

pub fn default() -> DriverConfig {
  DriverConfig(
    browser: browser_config.default_browser_type(),
    max_wait_time: default_max_wait_time,
    request_timeout: default_request_timeout,
    data_dir: default_data_dir,
  )
}
