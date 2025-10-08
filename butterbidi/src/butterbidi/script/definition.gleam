import butterbidi/script/types/evaluate_result
import gleam/dynamic/decode.{type Decoder}
import gleam/json.{type Json}

pub type ScriptCommand {
  CallFunction
}

pub fn script_command_to_json(command: ScriptCommand) -> Json {
  json.string(script_command_to_string(command))
}

pub fn script_command_to_string(command: ScriptCommand) -> String {
  case command {
    CallFunction -> "script.callFunction"
  }
}

pub type ScriptResult {
  EvaluateResult(evaluate_result: evaluate_result.EvaluateResult)
}

pub fn script_result_decoder(command: ScriptCommand) -> Decoder(ScriptResult) {
  case command {
    CallFunction -> {
      use call_function_result <- decode.then(
        evaluate_result.evaluate_result_decoder(),
      )
      decode.success(EvaluateResult(evaluate_result: call_function_result))
    }
  }
}
