import butterbee/bidi/method.{CallFunction}
import butterbee/bidi/script/types/evaluate_result.{
  type EvaluateResult, evaluate_result_decoder,
}
import butterbee/bidi/script/types/local_value.{
  type LocalValue, local_value_to_json,
}
import butterbee/bidi/script/types/target.{type Target}
import butterbee/internal/socket
import gleam/dynamic/decode
import gleam/json.{type Json}
import gleam/option.{type Option}

///
/// # [script.callFunction](https://w3c.github.io/webdriver-bidi/#command-script-callFunction)
///
/// Calls a function on the page with the given arguments.
///
/// ## Example
///
/// ```gleam
/// let result =
///   script.call_function(
///     driver.socket,
///     script.CallFunctionParameters(
///       function_declaration: "function(node) { return node.innerText; }",
///       await_promise: False,
///       target: target.Context(target.ContextTarget(driver.context, None)),
///       arguments: Some([
///         local_value.RemoteReference(
///           remote_reference.Shared(remote_reference.SharedReference(
///             shared_id,
///             None,
///           )),
///         ),
///       ]),
///     ),
///   )
/// ```
///
pub fn call_function(
  socket: socket.WebDriverSocket,
  params: CallFunctionParameters,
) -> EvaluateResult {
  let request =
    socket.bidi_request(
      method.to_string(CallFunction),
      call_function_parameters_to_json(params),
    )

  let assert Ok(result) =
    socket.send_request(socket, request)
    |> decode.run(evaluate_result_decoder())

  result
}

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

fn call_function_parameters_to_json(
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
