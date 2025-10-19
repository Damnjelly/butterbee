////
//// The page module contains functions to locate DOM nodes
////

import butterbee/commands/browsing_context
import butterbee/internal/retry
import butterbee/webdriver.{type WebDriver}
import butterbidi/browsing_context/commands/locate_nodes
import butterbidi/browsing_context/types/locator.{type Locator}
import butterbidi/definition
import butterbidi/script/types/remote_reference
import butterbidi/script/types/remote_value
import butterlib/log
import gleam/list
import gleam/option.{Some}
import gleam/result
import gleam/string

///
/// Finds a node matching the given locator, if multiple nodes are found, the first node is returned.
/// Will retry for a configurable amount of time to find a node.
/// Panics if no node is found after retrying for the configured amount of time.
/// 
/// # Example
///
/// This example finds the first node matching the css selector `a.logo`:
///
/// ```gleam
/// let example =
///   webdriver.new()
///   |> webdriver.goto("https://gleam.run/")
///   |> query.node(by.css("a.logo"))
/// ```
///
pub fn node(
  driver: WebDriver(state),
  locator: Locator,
) -> WebDriver(remote_value.NodeRemoteValue) {
  let driver = nodes(driver, locator)

  let nodes = webdriver.assert_state(driver)

  let err = "Found no, or more than one node: " <> string.inspect(nodes)
  let assert True = list.length(nodes) == 1 as err

  let assert Ok(node) = list.first(nodes) as err

  webdriver.map_state(Ok(node), driver)
}

///
/// Finds all nodes matching the given locator.
/// Will retry for a configurable amount of time to find all nodes.
/// 
/// # Example
///
/// This example finds all nodes matching the css selector `a.logo`:
///
/// ```gleam
/// let example =
///   webdriver.new()
///   |> webdriver.goto("https://gleam.run/")
///   |> query.nodes(by.css("a.logo"))
/// ```
///
pub fn nodes(
  driver: WebDriver(state),
  locator: Locator,
) -> WebDriver(List(remote_value.NodeRemoteValue)) {
  let params = locate_nodes.new(webdriver.get_context(driver), locator)

  locate_nodes(driver, params)
  |> result.map(fn(locate_nodes) { locate_nodes.nodes })
  |> webdriver.map_state(driver)
}

///
/// Query for a list of nodes from the position of another set of nodes.
pub fn from_node(
  driver: WebDriver(List(remote_value.NodeRemoteValue)),
  locator: Locator,
) -> WebDriver(remote_value.NodeRemoteValue) {
  let driver = from_nodes(driver, locator)

  let nodes = webdriver.assert_state(driver)

  let err = "Found no, or more than one node: " <> string.inspect(nodes)
  let assert True = list.length(nodes) == 1 as err

  let assert Ok(node) = list.first(nodes) as err

  webdriver.map_state(Ok(node), driver)
}

/// 
/// Query for a list of nodes from the position of another set of nodes.
/// 
/// Will retry for a configurable amount of time to find a node.
/// 
/// # Example
///
/// This example first finds all the package items, 
/// then refines the list of nodes to only contain the package names:
///
/// ```gleam
/// let example =
///   webdriver.new()
///   |> webdriver.goto("https://packages.gleam.run/")
///   |> query.nodes(by.css("div.package-item"))
///   |> query.refine(by.css("h2.package-name"))
/// ```
///
pub fn from_nodes(
  driver: WebDriver(List(remote_value.NodeRemoteValue)),
  locator: Locator,
) -> WebDriver(List(remote_value.NodeRemoteValue)) {
  let shared_ids =
    webdriver.assert_state(driver)
    |> list.map(fn(node) {
      let err = "Node does not have a shared id: " <> string.inspect(node)
      let assert Some(shared_id) = node.shared_id as err
      remote_reference.shared_reference_from_id(shared_id)
    })

  let params =
    locate_nodes.new(webdriver.get_context(driver), locator)
    |> locate_nodes.with_start_nodes(shared_ids)

  locate_nodes(driver, params)
  |> result.map(fn(locate_nodes) { locate_nodes.nodes })
  |> webdriver.map_state(driver)
}

pub fn locate_nodes(
  driver: WebDriver(state),
  params: locate_nodes.LocateNodesParameters,
) -> Result(locate_nodes.LocateNodesResult, definition.ErrorResponse) {
  retry.until_ok(fn() {
    case browsing_context.locate_nodes(driver, params) {
      Ok(locate_nodes_ok) ->
        case list.is_empty(locate_nodes_ok.nodes) {
          False -> Ok(locate_nodes_ok)
          True ->
            Error(definition.new_error_response(
              "Butterbee error",
              "No nodes found",
            ))
        }
      Error(locate_nodes_error) ->
        log.debug_and_continue(
          "Locating nodes failed, error: "
            <> string.inspect(locate_nodes_error)
            <> " retrying",
          Error(locate_nodes_error),
        )
    }
  })
}
