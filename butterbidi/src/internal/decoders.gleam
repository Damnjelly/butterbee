//// Generic decoders and encoders for the webdriver bidi protocol

import gleam/dynamic/decode
import logging
import youid/uuid.{type Uuid}

pub fn uuid() -> decode.Decoder(Uuid) {
  use str <- decode.then(decode.string)
  case uuid.from_string(str) {
    Ok(uuid) -> decode.success(uuid)
    Error(_) -> {
      logging.log(logging.Warning, "Invalid UUID format: " <> str)
      decode.success(uuid.nil)
    }
  }
}
