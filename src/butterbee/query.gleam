import butterbee/bidi/browsing_context/commands/browsing_context
import butterbee/bidi/script/types/remote_value
import butterbee/by.{type By}
import butterbee/driver
import butterbee/internal/retry
import gleam/list
import gleam/option.{None}

pub type Node {
  Node(value: remote_value.NodeRemoteValue)
}

pub fn node(driver: driver.WebDriver, by: By) -> #(driver.WebDriver, Node) {
  case nodes(driver, by) {
    #(webdriver, nodes) -> {
      let assert Ok(node) = list.first(nodes) as "No nodes found"
      #(webdriver, node)
    }
  }
}

pub fn nodes(
  driver: driver.WebDriver,
  by: By,
) -> #(driver.WebDriver, List(Node)) {
  let nodes =
    retry.till_true(
      fn() {
        let driver_with_nodes =
          browsing_context.locate_nodes(
            driver.socket,
            browsing_context.LocateNodesParameters(
              driver.context,
              by.locator,
              None,
              None,
            ),
          )

        let _nodes =
          { driver_with_nodes.1 }.nodes
          |> list.map(fn(node) { Node(node) })
      },
      fn(nodes) { !list.is_empty(nodes) },
    )

  #(driver, nodes)
}
