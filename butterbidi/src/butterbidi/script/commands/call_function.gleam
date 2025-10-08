import butterbidi/script/types/local_value.{type LocalValue, local_value_to_json}
import butterbidi/script/types/target.{type Target}
import gleam/json.{type Json}
import gleam/option.{type Option, None, Some}

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

pub fn new(target: Target) -> CallFunctionParameters {
  CallFunctionParameters(
    function_declaration: "",
    await_promise: False,
    target: target,
    arguments: None,
  )
}

pub fn with_function(
  call_function_parameters: CallFunctionParameters,
  function: String,
) -> CallFunctionParameters {
  CallFunctionParameters(
    ..call_function_parameters,
    function_declaration: function,
  )
}

pub fn with_await_promise(
  call_function_parameters: CallFunctionParameters,
) -> CallFunctionParameters {
  CallFunctionParameters(..call_function_parameters, await_promise: True)
}

pub fn with_arguments(
  call_function_parameters: CallFunctionParameters,
  arguments: List(LocalValue),
) -> CallFunctionParameters {
  CallFunctionParameters(..call_function_parameters, arguments: Some(arguments))
}
