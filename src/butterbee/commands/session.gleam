////
//// # [Session commands](https://w3c.github.io/webdriver-bidi/#module-session-commands)
////

import butterbee/bidi/definition
import butterbee/bidi/session/commands/new
import butterbee/bidi/session/definition as session_definition
import butterbee/bidi/session/types/capabilities_request.{
  type CapabilitiesRequest, capabilities_request_to_json,
}
import butterbee/internal/id
import butterbee/internal/socket
import gleam/http/request.{type Request}
import gleam/result

///
/// # [session.new](https://w3c.github.io/webdriver-bidi/#command-session-new)
///
/// Creates a new BiDi session with the given capabilities.
///
/// ## Example
///
/// ```gleam
/// let session =
///   session.new(CapabilitiesRequest(
///     Some(CapabilityRequest(None, None, None, None, [])),
///     None,
///   ))
/// ```
///
pub fn new(
  request: Request(String),
  capabilities_request: CapabilitiesRequest,
) -> #(socket.WebDriverSocket, Result(new.NewResult, definition.ErrorResponse)) {
  let socket = socket.new(request)
  let command = definition.SessionCommand(session_definition.New)
  let request =
    definition.command_to_json(
      definition.Command(id.from_unix(), command, [
        #("params", capabilities_request_to_json(capabilities_request)),
      ]),
    )

  let response =
    socket.send_request(socket, request, command)
    |> result.map(fn(response) {
      case response.result {
        definition.SessionResult(result) ->
          case result {
            session_definition.NewResult(result) -> result
            _ -> {
              panic as "Unexpected new result type"
            }
          }
        _ -> panic as "Unexpected session result type"
      }
    })

  #(socket, response)
}

///
/// # [session.end](https://w3c.github.io/webdriver-bidi/#command-session-end)
///
/// Closes the current session.
///
/// ## Example
///
/// ```gleam
/// session.end(socket)
/// ```
///
pub fn end(socket: socket.WebDriverSocket) -> Nil {
  let command = definition.SessionCommand(session_definition.End)
  let request =
    definition.command_to_json(
      definition.Command(id.from_unix(), command, [
        #("params", definition.empty_params_to_json(definition.EmptyParams([]))),
      ]),
    )

  let _ = socket.send_request(socket, request, command)

  Nil
}
