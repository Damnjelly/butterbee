////
//// ## [Session commands](https://w3c.github.io/webdriver-bidi/#module-session-commands)
////
//// The session commands module contains commands found in the session section of the
//// webdriver bidi protocol. Butterbee uses these internally to create the high level
//// API. But you can use these commands directly if you want something specific.
////
//// These commands usually expect parameter defined in the [butterbidi project](https://hexdocs.pm/butterbidi/index.html).
////

import butterbee/internal/id
import butterbee/internal/socket
import butterbidi/definition
import butterbidi/session/commands/new
import butterbidi/session/commands/status
import butterbidi/session/definition as session_definition
import butterbidi/session/types/capabilities_request.{
  type CapabilitiesRequest, capabilities_request_to_json,
}
import gleam/http/request.{type Request}
import gleam/result

///
/// Returns information about whether a remote end is in a state in which it can create
/// new sessions.
///
/// [w3c](https://w3c.github.io/webdriver-bidi/#command-session-status)
///
pub fn status(
  request: Request(String),
) -> Result(status.StatusResult, definition.ErrorResponse) {
  let socket = socket.new(request)
  let command = definition.SessionCommand(session_definition.Status)
  let request =
    definition.command_to_json(
      definition.Command(id.from_unix(), command, [
        #("params", definition.empty_params_to_json(definition.EmptyParams([]))),
      ]),
    )

  let response =
    socket.send_request(socket, request, command)
    |> result.map(fn(response) {
      case response.result {
        definition.SessionResult(result) ->
          case result {
            session_definition.StatusResult(result) -> result
            _ -> {
              panic as "Unexpected status result type"
            }
          }
        _ -> panic as "Unexpected session result type"
      }
    })

  response
}

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
/// [w3c](https://w3c.github.io/webdriver-bidi/#command-session-new)
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
/// Closes the current session.
///
/// [w3c](https://w3c.github.io/webdriver-bidi/#command-session-end)
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
