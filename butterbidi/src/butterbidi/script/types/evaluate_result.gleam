import butterbidi/script/types/remote_value.{
  type RemoteValue, remote_value_decoder,
}
import gleam/dynamic/decode.{type Decoder}
import logging

pub type EvaluateResult {
  SuccessResult(result: EvaluateResultSuccess)
  //TODO: ExceptionResult(EvaluateResultException)
}

pub fn evaluate_result_decoder() -> Decoder(EvaluateResult) {
  use result_type <- decode.field("type", decode.string)
  case result_type {
    "success" -> success_result_decoder()
    "exception" -> todo
    _ -> {
      logging.log(
        logging.Warning,
        "Unknown evaluate result type: " <> result_type,
      )
      panic as "Unknown evaluate result type"
    }
  }
}

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
