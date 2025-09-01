import butterbee/bidi/script/types/local_value.{
  type LocalValue, local_value_to_json,
}
import butterbee/bidi/script/types/target.{type Target}
import gleam/json.{type Json}
import gleam/option.{type Option}

pub type CallFunctionParameters {
  CallFunctionParameters(
    function_declaration: String,
    await_promise: Bool,
    target: Target,
    arguments: Option(List(LocalValue)),
    //TODO: result_ownership: Option(ResultOwnership),
    //TODO: serialization_options: Option(SerializationOptions),
    //TODO: this: Option(LocalValue),
    //TODO: user_activation: Option(Bool),
  )
}

pub fn call_function_parameters_to_json(
  call_function_parameters: CallFunctionParameters,
) -> Json {
  let CallFunctionParameters(
    function_declaration:,
    await_promise:,
    target:,
    arguments:,
  ) = call_function_parameters
  json.object([
    #("functionDeclaration", json.string(function_declaration)),
    #("awaitPromise", json.bool(await_promise)),
    #("target", target.target_to_json(target)),
    #("arguments", case arguments {
      option.None -> json.null()
      option.Some(value) -> json.array(value, local_value_to_json)
    }),
  ])
}
