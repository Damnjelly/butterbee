//// ## [Session commands](https://w3c.github.io/webdriver-bidi/#module-session-commands)
////
//// The session commands module contains commands found in the session section of the
//// webdriver bidi protocol. Butterbee uses these internally to create the high level
//// API. But you can use these commands directly if you want something specific.

import butterbee/internal/error
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

/// Returns information about whether a remote end is in a state in which it can create
/// new sessions.
///
/// [w3c](https://w3c.github.io/webdriver-bidi/#command-session-status)
pub fn status(
  request: Request(String),
) -> Result(status.StatusResult, error.ButterbeeError) {
  case socket.new(request) {
    Error(error) -> Error(error)
    Ok(socket) -> {
      let command = definition.SessionCommand(session_definition.Status)
      let request =
        definition.command_to_json(
          definition.Command(id.from_unix(), command, [
            #(
              "params",
              definition.empty_params_to_json(definition.EmptyParams([])),
            ),
          ]),
        )

      case socket.send_request(socket, request, command) {
        Error(error) -> Error(error)
        Ok(response) -> {
          case response.result {
            definition.SessionResult(result) ->
              case result {
                session_definition.StatusResult(result) -> Ok(result)
                _ -> Error(error.UnexpectedStatusResultType)
              }
            _ -> Error(error.UnexpectedSessionResultType)
          }
        }
      }
    }
  }
}

/// Creates a new BiDi session with the given capabilities.
///
/// ## Example
///
/// ```gleam
/// let session = session.new(capabilities.default)
/// ```
///
/// [w3c](https://w3c.github.io/webdriver-bidi/#command-session-new)
pub fn new(
  request: Request(String),
  capabilities_request: CapabilitiesRequest,
) -> Result(#(socket.WebDriverSocket, new.NewResult), error.ButterbeeError) {
  case socket.new(request) {
    Error(error) -> Error(error)
    Ok(socket) -> {
      let command = definition.SessionCommand(session_definition.New)
      let request =
        definition.command_to_json(
          definition.Command(id.from_unix(), command, [
            #("params", capabilities_request_to_json(capabilities_request)),
          ]),
        )
      case socket.send_request(socket, request, command) {
        Error(error) -> Error(error)
        Ok(response) -> {
          case response.result {
            definition.SessionResult(result) ->
              case result {
                session_definition.NewResult(result) -> Ok(result)
                _ -> Error(error.UnexpectedNewResultType)
              }
            _ -> Error(error.UnexpectedSessionResultType)
          }
          |> result.map(fn(new_result) { #(socket, new_result) })
        }
      }
    }
  }
}

/// Closes the current session.
///
/// [w3c](https://w3c.github.io/webdriver-bidi/#command-session-end)
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
