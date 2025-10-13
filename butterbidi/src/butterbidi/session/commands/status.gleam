import gleam/dynamic/decode

pub type StatusResult {
  StatusResult(ready: Bool, message: String)
}

pub fn status_result_decoder() -> decode.Decoder(StatusResult) {
  use ready <- decode.field("ready", decode.bool)
  use message <- decode.field("message", decode.string)
  decode.success(StatusResult(ready:, message:))
}
