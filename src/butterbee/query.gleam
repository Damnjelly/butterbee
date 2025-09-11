import butterbee/bidi/browsing_context/commands/locate_nodes
import butterbee/bidi/browsing_context/types/locator.{type Locator}
import butterbee/bidi/script/types/remote_reference
import butterbee/bidi/script/types/remote_value
import butterbee/commands/browsing_context
import butterbee/internal/retry
import butterbee/internal/socket
import butterbee/webdriver.{type WebDriver}
import gleam/list
import gleam/option.{Some}
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
pub fn node(driver: WebDriver, locator: Locator) -> #(WebDriver, List(Node)) {
  let #(webdriver, nodes) = case nodes(driver, locator) {
    #(webdriver, nodes) -> {
      let assert Ok(node) = list.first(nodes) as "No nodes found"
      #(webdriver, node)
    }
  }

  #(webdriver, [nodes])
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
pub fn nodes(driver: WebDriver, locator: Locator) -> #(WebDriver, List(Node)) {
  let params = locate_nodes.new(driver.context, locator)

  let nodes = locate_nodes(driver.socket, params)

  #(driver, nodes)
}

/// 
/// Query for a list of nodes from the position of another set of nodes.
/// 
/// Will retry for a configurable amount of time to find a node.
/// Panics if no node is found after retrying for the configured amount of time.
/// 
/// # Example
///
/// This example first finds all the package items, 
/// then refines the list of nodes to only contain the package names:
///
/// ```gleam
/// let example =
///   driver.new()
///   |> driver.goto("https://packages.gleam.run/")
///   |> query.nodes(by.css("div.package-item"))
///   |> query.refine(by.css("h2.package-name"))
/// ```
///
pub fn refine(
  webdriver_with_nodes: #(WebDriver, List(Node)),
  locator: Locator,
) -> #(WebDriver, List(Node)) {
  let #(driver, nodes) = webdriver_with_nodes

  let shared_ids =
    list.map(nodes, fn(node) {
      let assert Some(shared_id) = node.value.shared_id
        as "Some nodes have no shared id"
      remote_reference.shared_reference_from_id(shared_id)
    })

  let params =
    locate_nodes.new(driver.context, locator)
    |> locate_nodes.with_start_nodes(shared_ids)

  let nodes = locate_nodes(driver.socket, params)

  #(driver, nodes)
}

fn locate_nodes(
  socket: socket.WebDriverSocket,
  params: locate_nodes.LocateNodesParameters,
) -> List(Node) {
  let #(_, locate_nodes_result) =
    retry.until_ok(
      fn() { browsing_context.locate_nodes(socket, params) },
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

  nodes
}
