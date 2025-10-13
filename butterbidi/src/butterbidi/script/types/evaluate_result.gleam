////
//// [w3c link](https://w3c.github.io/webdriver-bidi/#type-script-EvaluateResult)
////

import butterbidi/script/types/exception_details.{
  type ExceptionDetails, exception_details_decoder,
}
import butterbidi/script/types/primitive_protocol_value
import butterbidi/script/types/remote_value.{
  type RemoteValue, remote_value_decoder,
}
import butterbidi/script/types/stack_trace
import butterlib/log
import gleam/dynamic/decode.{type Decoder}

pub type EvaluateResult {
  SuccessResult(result: EvaluateResultSuccess)
  ExceptionResult(result: EvaluateResultException)
}

pub fn evaluate_result_decoder() -> Decoder(EvaluateResult) {
  use result_type <- decode.field("type", decode.string)
  case result_type {
    "success" -> success_result_decoder()
    "exception" -> exception_result_decoder()
    _ ->
      log.error_and_continue(
        "Unknown evaluate result type: " <> result_type,
        decode.failure(evaulate_result_failure, "Unknown evaluate result type"),
      )
  }
}

pub const evaulate_result_failure = ExceptionResult(
  EvaluateResultException(
    result_type: Exception,
    exception_details: exception_details.ExceptionDetails(
      column_number: 0,
      exception: remote_value.PrimitiveProtocol(
        primitive_protocol_value.Undefined(
          primitive_protocol_value.UndefinedValue("undefined"),
        ),
      ),
      line_number: 0,
      stack_trace: stack_trace.StackTrace(call_frames: []),
      text: "Butterbee Evaluate Result Failure",
    ),
  ),
)

pub type EvaluateResultSuccess {
  EvaluateResultSuccess(
    result_type: EvaluateResultType,
    result: RemoteValue,
    //TODO: realm: Realm
  )
}

fn success_result_decoder() -> Decoder(EvaluateResult) {
  use result <- decode.field("result", remote_value_decoder())
  decode.success(
    SuccessResult(EvaluateResultSuccess(result_type: Success, result:)),
  )
}

pub type EvaluateResultException {
  EvaluateResultException(
    result_type: EvaluateResultType,
    exception_details: ExceptionDetails,
    //TODO: realm: Realm
  )
}

fn exception_result_decoder() -> Decoder(EvaluateResult) {
  use exception_details <- decode.field(
    "exceptionDetails",
    exception_details_decoder(),
  )
  decode.success(
    ExceptionResult(EvaluateResultException(
      result_type: Exception,
      exception_details:,
    )),
  )
}

pub type EvaluateResultType {
  Success
  Exception
}
