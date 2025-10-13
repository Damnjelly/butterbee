////
//// [w3c link](https://w3c.github.io/webdriver-bidi/#type-script-StackTrace)
////

import butterbidi/script/types/stack_frame.{type StackFrame, stack_frame_decoder}
import gleam/dynamic/decode

pub type StackTrace {
  StackTrace(call_frames: List(StackFrame))
}

pub fn stack_trace_decoder() -> decode.Decoder(StackTrace) {
  use call_frames <- decode.field(
    "callFrames",
    decode.list(stack_frame_decoder()),
  )
  decode.success(StackTrace(call_frames:))
}
