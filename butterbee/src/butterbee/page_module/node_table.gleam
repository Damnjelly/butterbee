import butterbee/get
import butterbee/webdriver.{type WebDriver}
import butterbidi/browsing_context/types/locator.{type Locator}

pub type NodeTable {
  Table
  Row(Int)
  Cell(Int, Int)
}

pub fn define(
  table table_locator: Locator,
  table_row table_row_locator: Locator,
  table_cell table_cell_locator: Locator,
) -> #(Locator, Locator, Locator) {
  #(table_locator, table_row_locator, table_cell_locator)
}

pub fn perform_action(
  locator: #(Locator, Locator, Locator),
  driver: WebDriver(state),
  on_element: NodeTable,
  action: fn(_) -> WebDriver(new_state),
) -> WebDriver(new_state) {
  let #(table_locator, table_row_locator, table_cell_locator) = locator

  case on_element {
    Table -> get.node(driver, table_locator)
    Row(row) -> {
      driver
      |> get.node(table_locator)
      |> get.nodes_from_node(table_row_locator)
      |> get.node_from_nodes(row + 1)
    }
    Cell(row, column) -> {
      driver
      |> get.node(table_locator)
      |> get.nodes_from_node(table_row_locator)
      |> get.node_from_nodes(row + 1)
      |> get.nodes_from_node(table_cell_locator)
      |> get.node_from_nodes(column + 1)
    }
  }
  |> action
}
