//// The driver config module contains functions for parsing and creating driver
//// configurations. The driver configuration specifies general options the webdriver
//// needs to run, such as the maximum wait time, and the request timeout.
////
//// ### TOML Configuration Format
////
//// The driver configuration is defined under the
//// `[tools.butterbee.driver]` section of your `gleam.toml` file:
////
//// ```toml
//// # gleam.toml
////
//// [tools.butterbee.driver]
//// max_wait_time = 20000
//// request_timeout = 5000
//// data_dir = "/tmp/butterbee"
//// ```

import gleam/dynamic/decode

/// Butterbee will use this maximum wait time unless overridden.
/// This settings determines how long butterbee will perform a retry function for
/// before timing out (and failing the test).
pub const default_max_wait_time: Int = 20_000

/// Butterbee will use this request timeout unless overridden.
/// Warn: This value is not currently used.
pub const default_request_timeout: Int = 5000

/// Butterbee will use this data directory unless overridden.
/// The data directory is used to store profile data for browsers.
pub const default_data_dir: String = "/tmp/butterbee"

pub type DriverConfig {
  DriverConfig(max_wait_time: Int, request_timeout: Int, data_dir: String)
}

pub const default: DriverConfig = DriverConfig(
  max_wait_time: default_max_wait_time,
  request_timeout: default_request_timeout,
  data_dir: default_data_dir,
)

@internal
pub fn driver_config_decoder() -> decode.Decoder(DriverConfig) {
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

  decode.success(DriverConfig(max_wait_time:, request_timeout:, data_dir:))
}
