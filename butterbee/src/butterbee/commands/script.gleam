////
//// # [Script commands](https://w3c.github.io/webdriver-bidi/#module-script-commands)
////
//// The script commands module contains commands found in the script section of the
//// webdriver bidi protocol. Butterbee uses these internally to create the high level
//// API. But you can use these commands directly if you want something specific.
////
//// These commands usually expect parameter defined in the [butterbdi project](https://hexdocs.pm/butterbidi/index.html).
////  

import butterbee/internal/id
import butterbee/internal/socket
import butterbidi/definition
import butterbidi/script/commands/call_function.{
  type CallFunctionParameters, call_function_parameters_to_json,
}
import butterbidi/script/definition as script_definition
import butterbidi/script/types/evaluate_result.{type EvaluateResult}
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
///   webdriver.socket
///   |> script.call_function(call_function.CallFunctionParameters(
///     function_declaration: "function(node) { return node.innerText; }",
///     await_promise: False,
///     target: target.Context(target.ContextTarget(webdriver.context, None)),
///     arguments: Some([
///       local_value.RemoteReference(
///         remote_reference.Shared(remote_reference.SharedReference(
///           shared_id,
///           None,
///         )),
///       ),
///     ]),
///   ))
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
      definition.ScriptResult(result) -> result
      _ -> panic as "Unexpected script result type"
    }.evaluate_result
  })
}
