import butterbee/bidi/definition
import butterbee/bidi/script/commands/call_function.{
  type CallFunctionParameters, call_function_parameters_to_json,
}
import butterbee/bidi/script/definition as script_definition
import butterbee/bidi/script/types/evaluate_result.{
  type EvaluateResult, evaluate_result_decoder,
}
import butterbee/internal/id
import butterbee/internal/socket
import gleam/dynamic/decode
import gleam/result

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
///     call_function.CallFunctionParameters(
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
) -> Result(EvaluateResult, definition.ErrorResponse) {
  let command = definition.ScriptCommand(script_definition.CallFunction)
  let request =
    definition.command_to_json(
      definition.Command(id.from_unix(), command, [
        #("params", call_function_parameters_to_json(params)),
      ]),
    )

  socket.send_request(socket, request, command)
  |> result.map(fn(response) {
    case response.result {
      definition.ScriptResult(result) ->
        case result {
          script_definition.EvaluateResult(result) -> result
          _ -> {
            panic as "Unexpected evaluate result type"
          }
        }
      _ -> panic as "Unexpected script result type"
    }
  })
}
