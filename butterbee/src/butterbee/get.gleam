//// The action module contains functions to get elements from the DOM
////
//// ## Usage
////
//// After navigating to a page, call one of the functions in this module to get a node,
//// or a list of nodes. After getting a node, you can perform actions on it using functions from
//// the [`node`](https://hexdocs.pm/butterbee/node.html) and 
//// [`action`](https://hexdocs.pm/butterbee/action.html) modules.
//// Butterbee supports different locating strategies, see the 
//// [by](https://hexdocs.pm/butterbee/by.html) module for more information.
////
//// ### Example
////
//// This example gets a node from the page, and then performs an action on it:
////
//// ```gleam
//// let example =
////   driver
////   // navigate to a page
////   |> driver.goto("https://gleam.run/")
////   // get the node matching the css selector `a.logo` 
////   // and adds it to the state of the webdriver
////   |> get.node(by.css("a.logo"))
////   // perform actions on the node that was queried above
////   |> node.get(node.text()) 
//// ```
//// 
//// getting nodes directly is useful for one-off situations, 
//// but if you want to make your tests more reusable, its recommended to use 
//// [page modules](https://hexdocs.pm/butterbee/page-modules.html).

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

/// Finds a node matching the given locator. 
/// If multiple nodes are found, the first node is returned.
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

/// Finds all nodes matching the given locator.
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

/// Finds a node matching the given locator starting from the node in state.
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

/// Finds a list of nodes matching the given locator starting from the node in state.
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

/// Finds a node matching the given index starting from the list of nodes in state.
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

/// Performs the locate nodes command, retries until a node is found, or until 
/// the timeout is reached.
@internal
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
