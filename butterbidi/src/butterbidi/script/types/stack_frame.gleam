////
//// [w3c link](https://w3c.github.io/webdriver-bidi/#type-script-StackFrame)
////

import gleam/dynamic/decode

pub type StackFrame {
  StackFrame(
    column_number: Int,
    function_name: String,
    line_number: Int,
    url: String,
  )
}

pub fn stack_frame_decoder() -> decode.Decoder(StackFrame) {
  use column_number <- decode.field("columnNumber", decode.int)
  use function_name <- decode.field("functionName", decode.string)
  use line_number <- decode.field("lineNumber", decode.int)
  use url <- decode.field("url", decode.string)
  decode.success(StackFrame(column_number:, function_name:, line_number:, url:))
}
