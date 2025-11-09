//// Generic decoders and encoders for the webdriver bidi protocol

import gleam/dynamic/decode
import palabres as log
import youid/uuid.{type Uuid}

pub fn uuid() -> decode.Decoder(Uuid) {
  use str <- decode.then(decode.string)
  case uuid.from_string(str) {
    Ok(uuid) -> decode.success(uuid)
    Error(_) -> {
      log.warning("Invalid UUID format")
      |> log.string("uuid", str)
      |> log.log
      decode.success(uuid.nil)
    }
  }
}
