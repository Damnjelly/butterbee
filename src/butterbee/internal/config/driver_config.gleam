import gleam/dict.{type Dict}
import gleam/dynamic/decode
import gleam/option.{type Option, None, Some}
import gleam/result
import tom

pub type DriverConfig {
  DriverConfig(
    browser: Option(String),
    max_wait_time: Int,
    request_timeout: Int,
    data_dir: String,
  )
}

pub fn driver_config_decoder() -> decode.Decoder(DriverConfig) {
  use browser <- decode.field("browser", decode.optional(decode.string))
  use max_wait_time <- decode.field("max_wait_time", decode.int)
  use request_timeout <- decode.field("request_timeout", decode.int)
  use data_dir <- decode.field("data_dir", decode.string)
  decode.success(DriverConfig(
    browser:,
    max_wait_time:,
    request_timeout:,
    data_dir:,
  ))
}

pub fn default() -> DriverConfig {
  DriverConfig(
    browser: None,
    max_wait_time: 20_000,
    request_timeout: 5000,
    data_dir: "/tmp/butterbee",
  )
}

pub fn driver_config_from_toml(config: Dict(String, tom.Toml)) -> DriverConfig {
  let browser =
    tom.get_string(config, ["Driver", "browser"])
    |> option.from_result()

  let max_wait_time =
    tom.get_int(config, ["Driver", "max_wait_time"])
    |> result.unwrap(20_000)

  let request_timeout =
    tom.get_int(config, ["Driver", "request_timeout"])
    |> result.unwrap(5000)

  let data_dir =
    tom.get_string(config, ["Driver", "data_dir"])
    |> result.unwrap("/tmp/butterbee")

  DriverConfig(browser:, max_wait_time:, request_timeout:, data_dir:)
}
