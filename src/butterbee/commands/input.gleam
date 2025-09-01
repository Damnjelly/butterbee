import butterbee/bidi/definition
import butterbee/bidi/input/commands/perform_actions.{
  perform_actions_parameters_to_json,
}
import butterbee/bidi/input/definition as input_definition
import butterbee/internal/id
import butterbee/internal/socket
import gleam/result

///
/// # [input.performActions](https://w3c.github.io/webdriver-bidi/#command-input-performActions)
///
/// The input.performActions command performs a specified sequence of user input actions.
/// 
/// ## Example
///
/// ```gleam
/// let socket =
///   input.perform_actions(
///     driver.socket,
///     perform_actions.PerformActionsParameters(driver.context, [
///       perform_actions.PointerSource(
///         perform_actions.PointerSourceActions("mouse", None, [
///           perform_actions.PointerMove(perform_actions.PointerMoveAction(
///             0,
///             0,
///             option.None,
///             option.Some(
///               perform_actions.Element(
///                 element_origin.ElementOrigin(remote_reference.SharedReference(
///                   shared_id,
///                   option.None,
///                 )),
///               ),
///             ),
///           )),
///           perform_actions.PointerDown(perform_actions.PointerDownAction(0)),
///           perform_actions.PointerUp(perform_actions.PointerUpAction(0)),
///         ]),
///       ),
///     ]),
///   )
/// ```
///
pub fn perform_actions(
  socket: socket.WebDriverSocket,
  params: perform_actions.PerformActionsParameters,
) -> #(
  socket.WebDriverSocket,
  Result(definition.CommandResponse, definition.ErrorResponse),
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
