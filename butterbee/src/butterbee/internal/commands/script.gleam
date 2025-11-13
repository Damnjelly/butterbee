//// ## [Script commands](https://w3c.github.io/webdriver-bidi/#module-script-commands)
////
//// The script commands module contains commands found in the script section of the
//// webdriver bidi protocol. Butterbee uses these internally to create the high level
//// API. But you can use these commands directly if you want something specific.

import butterbee/internal/error
import butterbee/internal/id
import butterbee/internal/socket
import butterbee/webdriver
import butterbidi/definition
import butterbidi/script/commands/call_function.{
  type CallFunctionParameters, call_function_parameters_to_json,
}
import butterbidi/script/definition as script_definition
import butterbidi/script/types/evaluate_result.{type EvaluateResult}
import gleam/result

/// Calls a function on the page with the given arguments.
///
/// ## Example
///
/// ```gleam
/// let function_params =
///   call_function.new(target)
///   |> call_function.with_function(function)
///   |> call_function.with_arguments(arguments)
/// ```
///
/// [w3c](https://w3c.github.io/webdriver-bidi/#command-script-callFunction)
pub fn call_function(
  driver: webdriver.WebDriver(state),
  params: CallFunctionParameters,
) -> Result(EvaluateResult, error.ButterbeeError) {
  let command = definition.ScriptCommand(script_definition.CallFunction)
  let request =
    definition.command_to_json(
      definition.Command(id.from_unix(), command, [
        #("params", call_function_parameters_to_json(params)),
      ]),
    )

  use socket <- result.try({ webdriver.get_socket(driver) })

  case socket.send_request(socket, request, command) {
    Error(error) -> Error(error)
    Ok(response) -> {
      case response.result {
        definition.ScriptResult(result) -> Ok(result.evaluate_result)
        _ -> Error(error.UnexpectedScriptResultType)
      }
    }
  }
}
