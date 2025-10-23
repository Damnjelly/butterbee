////
//// The page module contains functions to locate DOM nodes
////

import butterbee/commands/browsing_context
import butterbee/internal/error
import butterbee/internal/retry
import butterbee/webdriver.{type WebDriver}
import butterbidi/browsing_context/commands/locate_nodes
import butterbidi/browsing_context/types/locator.{type Locator}
import butterbidi/script/types/remote_reference
import butterbidi/script/types/remote_value
import gleam/list
import gleam/option
import gleam/result

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

  result.try(driver.state, fn(nodes) {
    case list.length(nodes) {
      1 ->
        case list.first(nodes) {
          Ok(node) -> Ok(node)
          Error(_) -> Error(error.NoNodeFound)
        }
      _ -> Error(error.MoreThanOneNodeFound)
    }
  })
  |> webdriver.map_state(driver)
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
  result.try(
    {
      driver.context
      |> option.to_result(error.DriverDoesNotHaveContext)
    },
    fn(context) {
      let params = locate_nodes.new(context, locator)

      locate_nodes(driver, params)
      |> result.map(fn(locate_nodes) { locate_nodes.nodes })
    },
  )
  |> webdriver.map_state(driver)
}

pub fn from_node(
  driver: WebDriver(remote_value.NodeRemoteValue),
  locator: Locator,
) -> WebDriver(remote_value.NodeRemoteValue) {
  result.try({ driver.state }, fn(node) {
    use shared_id <- result.try({
      node.shared_id
      |> option.to_result(error.NodeDoesNotHaveSharedId)
    })

    use context <- result.try({ webdriver.get_context(driver) })

    let params =
      locate_nodes.new(context, locator)
      |> locate_nodes.with_start_nodes([
        remote_reference.shared_reference_from_id(shared_id),
      ])

    use locate_nodes <- result.try({ locate_nodes(driver, params) })

    let nodes = locate_nodes.nodes
    case list.length(nodes) {
      1 ->
        case list.first(nodes) {
          Ok(node) -> Ok(node)
          Error(_) -> Error(error.NoNodeFound)
        }
      _ -> Error(error.MoreThanOneNodeFound)
    }
  })
  |> webdriver.map_state(driver)
}

/// 
/// Query for a list of nodes from the position of another nodes.
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
pub fn nodes_from_node(
  driver: WebDriver(remote_value.NodeRemoteValue),
  locator: Locator,
) -> WebDriver(List(remote_value.NodeRemoteValue)) {
  result.try({ driver.state }, fn(node) {
    use shared_id <- result.try({
      node.shared_id
      |> option.to_result(error.NodeDoesNotHaveSharedId)
    })

    use context <- result.try({ webdriver.get_context(driver) })

    let params =
      locate_nodes.new(context, locator)
      |> locate_nodes.with_start_nodes([
        remote_reference.shared_reference_from_id(shared_id),
      ])

    locate_nodes(driver, params)
    |> result.map(fn(locate_nodes) { locate_nodes.nodes })
  })
  |> webdriver.map_state(driver)
}

pub fn node_from_nodes(
  driver: WebDriver(List(remote_value.NodeRemoteValue)),
  index: Int,
) -> WebDriver(remote_value.NodeRemoteValue) {
  case driver.state {
    Error(_) -> Error(error.DriverDoesNotHaveState)
    Ok(nodes) -> {
      list.last(list.take(nodes, index + 1))
      |> result.map_error(fn(_) { error.NoNodeFound })
    }
  }
  |> webdriver.map_state(driver)
}

pub fn locate_nodes(
  driver: WebDriver(state),
  params: locate_nodes.LocateNodesParameters,
) -> Result(locate_nodes.LocateNodesResult, error.ButterbeeError) {
  retry.until_ok(fn() {
    case browsing_context.locate_nodes(driver, params) {
      Ok(locate_nodes_ok) ->
        case list.is_empty(locate_nodes_ok.nodes) {
          False -> Ok(locate_nodes_ok)
          True -> Error(error.NoNodeFound)
        }
      Error(error) -> Error(error)
    }
  })
}
