////
//// [w3c link](https://w3c.github.io/webdriver-bidi/#type-script-ExceptionDetails)
////

import butterbidi/script/types/remote_value.{
  type RemoteValue, remote_value_decoder,
}
import butterbidi/script/types/stack_trace.{type StackTrace, stack_trace_decoder}
import gleam/dynamic/decode

pub type ExceptionDetails {
  ExceptionDetails(
    column_number: Int,
    exception: RemoteValue,
    line_number: Int,
    stack_trace: StackTrace,
    text: String,
  )
}

pub fn exception_details_decoder() -> decode.Decoder(ExceptionDetails) {
  use column_number <- decode.field("columnNumber", decode.int)
  use exception <- decode.field("exception", remote_value_decoder())
  use line_number <- decode.field("lineNumber", decode.int)
  use stack_trace <- decode.field("stackTrace", stack_trace_decoder())
  use text <- decode.field("text", decode.string)
  decode.success(ExceptionDetails(
    column_number:,
    exception:,
    line_number:,
    stack_trace:,
    text:,
  ))
}
