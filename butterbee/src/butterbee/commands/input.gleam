////
//// ## [Input commands](https://w3c.github.io/webdriver-bidi/#module-input-commands)
////
//// The input commands module contains commands found in the input section of the
//// webdriver bidi protocol. Butterbee uses these internally to create the high level
//// API. But you can use these commands directly if you want something specific.
////
//// These commands usually expect parameter defined in the [butterbidi project](https://hexdocs.pm/butterbidi/index.html).
////

import butterbee/internal/error
import butterbee/internal/id
import butterbee/internal/socket
import butterbidi/definition
import butterbidi/input/commands/perform_actions.{
  perform_actions_parameters_to_json,
}
import butterbidi/input/definition as input_definition

///
/// The input.performActions command performs a specified sequence of user input actions.
/// 
/// ## Example
///
/// ```gleam
/// let click =
///   perform_actions.default(driver.context)
///   |> perform_actions.with_actions([
///     {
///       perform_actions.pointer_actions("mouse", [
///         move_to_element(shared_id),
///         perform_actions.pointer_down_action(mouse_button_to_int(mouse_button)),
///         perform_actions.pointer_up_action(mouse_button_to_int(mouse_button)),
///       ])
///     },
///   ])
/// ```
///
/// [w3c](https://w3c.github.io/webdriver-bidi/#command-input-performActions)
///
pub fn perform_actions(
  socket: socket.WebDriverSocket,
  params: perform_actions.PerformActionsParameters,
) -> #(
  socket.WebDriverSocket,
  Result(definition.CommandResponse, error.ButterbeeError),
) {
  let command = definition.InputCommand(input_definition.PerformActions)
  let request =
    definition.command_to_json(
      definition.Command(id.from_unix(), command, [
        #("params", perform_actions_parameters_to_json(params)),
      ]),
    )

  let response = socket.send_request(socket, request, command)

  #(socket, response)
}
