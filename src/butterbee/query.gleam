import butterbee/by.{type By}
import butterbee/driver
import butterbee/internal/bidi/browsing_context
import butterbee/internal/bidi/script
import gleam/list
import gleam/option.{None}

pub type Node {
  Node(value: script.NodeRemoteValue)
}

pub fn element(driver: driver.WebDriver, by: By) -> #(driver.WebDriver, Node) {
  case elements(driver, by) {
    #(webdriver, nodes) -> {
      let assert Ok(node) = list.first(nodes)
      #(webdriver, node)
    }
  }
}

pub fn elements(
  driver: driver.WebDriver,
  by: By,
) -> #(driver.WebDriver, List(Node)) {
  let driver_with_nodes =
    browsing_context.locate_nodes(
      #(driver.socket, driver.context),
      by.locator,
      None,
      None,
    )

  let webdriver = driver.WebDriver(driver_with_nodes.0.0, driver_with_nodes.0.1)
  let nodes =
    driver_with_nodes.1
    |> list.map(fn(node) { Node(node) })

  #(webdriver, nodes)
}
