//// Generic decoders and encoders for the webdriver bidi protocol

import butterlib/log
import gleam/dynamic/decode
import youid/uuid.{type Uuid}

pub fn uuid() -> decode.Decoder(Uuid) {
  use str <- decode.then(decode.string)
  case uuid.from_string(str) {
    Ok(uuid) -> decode.success(uuid)
    Error(_) ->
      log.warning_and_continue(
        "Invalid UUID format: " <> str,
        decode.success(uuid.nil),
      )
  }
}
