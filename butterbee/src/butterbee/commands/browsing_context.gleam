//// ## [Browsing context commands](https://w3c.github.io/webdriver-bidi/#module-browsing-context-commands) 
////
//// The browsing context commands module contains commands found in the browsing context section of the
//// webdriver bidi protocol. Butterbee uses these internally to create the high level
//// API. But you can use these commands directly if you want something specific.

import butterbee/internal/error
import butterbee/internal/id
import butterbee/internal/socket
import butterbee/webdriver.{type WebDriver}
import butterbidi/browsing_context/commands/get_tree.{
  get_tree_parameters_to_json,
}
import butterbidi/browsing_context/commands/locate_nodes.{
  locate_nodes_parameters_to_json,
}
import butterbidi/browsing_context/commands/navigate.{
  navigate_parameters_to_json,
}
import butterbidi/browsing_context/definition as browsing_context_definition
import butterbidi/browsing_context/types/readiness_state
import butterbidi/definition
import gleam/json
import gleam/option.{None, Some}
import gleam/result

/// Returns a tree of all descendent navigables including the given 
/// parent itself, or all top-level contexts when no parent is provided.
/// 
/// ## Example
///
/// ```gleam
/// let browsing_tree =
///   browsing_context.get_tree(driver.socket, get_tree.default())
///   )
/// ```
///
/// [w3c](https://w3c.github.io/webdriver-bidi/#command-browsingContext-getTree)
pub fn get_tree(
  driver: WebDriver(state),
  params: get_tree.GetTreeParameters,
) -> Result(get_tree.GetTreeResult, error.ButterbeeError) {
  let command =
    definition.BrowsingContextCommand(browsing_context_definition.GetTree)
  let request =
    definition.command_to_json(
      definition.Command(id.from_unix(), command, [
        #("params", get_tree_parameters_to_json(params)),
      ]),
    )
  use socket <- result.try({ webdriver.get_socket(driver) })

  use response <- result.try({ socket.send_request(socket, request, command) })

  case response.result {
    definition.BrowsingContextResult(result) ->
      case result {
        browsing_context_definition.GetTreeResult(result) -> Ok(result)
        _ -> Error(error.UnexpectedGetTreeResultType)
      }
    _ -> Error(error.UnexpectedBrowsingContextResultType)
  }
}

/// Returns a list of all nodes matching the specified locator.
/// 
/// ## Example
///
/// ```gleam
/// let nodes = locate_nodes(
///   driver.socket, 
///   locate_nodes.new(driver.context, locator)
/// )
/// ```
///
/// [w3c](https://w3c.github.io/webdriver-bidi/#command-browsingContext-locateNodes)
pub fn locate_nodes(
  driver: WebDriver(state),
  params: locate_nodes.LocateNodesParameters,
) -> Result(locate_nodes.LocateNodesResult, error.ButterbeeError) {
  let command =
    definition.BrowsingContextCommand(browsing_context_definition.LocateNodes)

  let request =
    definition.command_to_json(
      definition.Command(id.from_unix(), command, [
        #("params", locate_nodes_parameters_to_json(params)),
      ]),
    )

  use socket <- result.try({ webdriver.get_socket(driver) })

  use response <- result.try({ socket.send_request(socket, request, command) })

  case response.result {
    definition.BrowsingContextResult(result) ->
      case result {
        browsing_context_definition.LocateNodesResult(result) -> Ok(result)
        _ -> Error(error.UnexpectedBrowsingContextResultType)
      }
    _ -> Error(error.UnexpectedBrowsingContextResultType)
  }
}

/// Navigates a navigable to the given URL.
/// 
/// ## Example
///
/// ```gleam
/// let driver =
///   browsing_context.navigate(
///     driver.socket, navigate.default(driver.context, url))
/// ```
///
/// [w3c](https://w3c.github.io/webdriver-bidi/#command-browsingContext-navigate)
pub fn navigate(
  driver: WebDriver(state),
  params: navigate.NavigateParameters,
) -> Result(navigate.NavigateResult, error.ButterbeeError) {
  let command =
    definition.BrowsingContextCommand(browsing_context_definition.Navigate)

  let _wait = case params.wait {
    None -> []
    Some(state) -> [
      #(
        "wait",
        json.nullable(
          Some(readiness_state.readiness_state_to_string(state)),
          json.string,
        ),
      ),
    ]
  }

  let request =
    definition.command_to_json(
      definition.Command(id.from_unix(), command, [
        #("params", navigate_parameters_to_json(params)),
      ]),
    )

  use socket <- result.try({ webdriver.get_socket(driver) })

  use response <- result.try({ socket.send_request(socket, request, command) })

  case response.result {
    definition.BrowsingContextResult(result) ->
      case result {
        browsing_context_definition.NavigateResult(result) -> Ok(result)
        _ -> Error(error.UnexpectedBrowsingContextResultType)
      }
    _ -> Error(error.UnexpectedBrowsingContextResultType)
  }
}
