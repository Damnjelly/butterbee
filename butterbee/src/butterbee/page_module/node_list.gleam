import butterbee/get
import butterbee/webdriver.{type WebDriver}
import butterbidi/browsing_context/types/locator.{type Locator}

pub type NodeList {
  List
  Row(Int)
}

pub fn define(
  list list_locator: Locator,
  list_item list_item_locator: Locator,
) -> #(Locator, Locator) {
  #(list_locator, list_item_locator)
}

pub fn perform_action(
  locator: #(Locator, Locator),
  driver: WebDriver(state),
  on_element: NodeList,
  action: fn(_) -> WebDriver(new_state),
) -> WebDriver(new_state) {
  let #(list_locator, list_item_locator) = locator

  case on_element {
    List -> get.node(driver, list_locator)
    Row(row) -> {
      driver
      |> get.node(list_locator)
      |> get.nodes_from_node(list_item_locator)
      |> get.node_from_nodes(row + 1)
    }
  }
  |> action
}
