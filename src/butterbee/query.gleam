import butterbee/bidi/browsing_context/commands/locate_nodes
import butterbee/bidi/browsing_context/types/locator.{type Locator}
import butterbee/bidi/script/types/remote_value
import butterbee/commands/browsing_context
import butterbee/driver
import butterbee/internal/retry
import gleam/list
import gleam/option.{None}
import gleam/string
import logging

pub type Node {
  Node(value: remote_value.NodeRemoteValue)
}

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
///   driver.new()
///   |> driver.goto("https://gleam.run/")
///   |> query.node(by.css("a.logo"))
/// ```
///
pub fn node(
  driver: driver.WebDriver,
  locator: Locator,
) -> #(driver.WebDriver, Node) {
  case nodes(driver, locator) {
    #(webdriver, nodes) -> {
      let assert Ok(node) = list.first(nodes) as "No nodes found"
      #(webdriver, node)
    }
  }
}

///
/// Finds all nodes matching the given locator.
/// Will retry for a configurable amount of time to find all nodes.
/// Panics if no nodes are found after retrying for the configured amount of time.
/// 
/// # Example
///
/// This example finds all nodes matching the css selector `a.logo`:
///
/// ```gleam
/// let example =
///   driver.new()
///   |> driver.goto("https://gleam.run/")
///   |> query.nodes(by.css("a.logo"))
/// ```
///
pub fn nodes(
  driver: driver.WebDriver,
  locator: Locator,
) -> #(driver.WebDriver, List(Node)) {
  let #(socket, locate_nodes_result) =
    retry.until_ok(
      fn() {
        browsing_context.locate_nodes(
          driver.socket,
          locate_nodes.LocateNodesParameters(
            driver.context,
            locator,
            None,
            None,
          ),
        )
      },
      fn(locate_nodes_result) {
        case locate_nodes_result.1 {
          Ok(locate_nodes_ok) ->
            case !list.is_empty(locate_nodes_ok.nodes) {
              True -> Ok(locate_nodes_ok)
              False -> {
                logging.log(logging.Debug, "No nodes found, retrying")
                Error(Nil)
              }
            }
          Error(locate_nodes_error) -> {
            logging.log(
              logging.Debug,
              "Locating nodes failed, error: "
                <> string.inspect(locate_nodes_error)
                <> " retrying",
            )
            Error(Nil)
          }
        }
      },
    )

  let assert Ok(locate_nodes_result) = locate_nodes_result

  let nodes =
    locate_nodes_result.nodes
    |> list.map(fn(node) { Node(node) })

  let webdriver = driver.WebDriver(socket, driver.context, driver.config)

  #(webdriver, nodes)
}

pub fn refine(
  webdriver_with_node: #(driver.WebDriver, nodes),
  locator: Locator,
) -> #(driver.WebDriver, List(Node)) {
  todo
}
