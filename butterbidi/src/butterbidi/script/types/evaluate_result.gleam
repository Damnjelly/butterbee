import butterbidi/script/types/primitive_protocol_value
import butterbidi/script/types/remote_value.{
  type RemoteValue, remote_value_decoder,
}
import butterlib/log
import gleam/dynamic/decode.{type Decoder}

pub type EvaluateResult {
  SuccessResult(result: EvaluateResultSuccess)
  //TODO: ExceptionResult(EvaluateResultException)
}

pub fn evaluate_result_decoder() -> Decoder(EvaluateResult) {
  use result_type <- decode.field("type", decode.string)
  case result_type {
    "success" -> success_result_decoder()
    "exception" -> todo
    _ ->
      log.error_and_continue(
        "Unknown evaluate result type: " <> result_type,
        decode.failure(evaulate_result_failure, "Unknown evaluate result type"),
      )
  }
}

const evaulate_result_failure = SuccessResult(
  EvaluateResultSuccess(
    result_type: Exception,
    result: remote_value.PrimitiveProtocol(
      primitive_protocol_value.Undefined(
        primitive_protocol_value.UndefinedValue("undefined"),
      ),
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

//TODO: pub type EvaluateResultException {
//   EvaluateResultException(result_type: EvaluateResultType)
// }

pub type EvaluateResultType {
  Success
  Exception
}
