//// Define elements for page module using this module.
////
//// Example:
////
//// ```gleam
//// import butterbee/page_module/table_element.{type NodeTable}
////
//// pub fn pokedex_table(
////   driver: WebDriver(state),
////   on_element: NodeTable,
////   action: fn(_) -> WebDriver(new_state),
//// ) {
////   table_element.define(
////     table: by.css("table#pokedex"),
////     table_row: by.css("tr"),
////     table_cell: by.css("td"),
////     table_width: 3,
////   )
////   |> table_element.perform_action(driver, on_element, action)
//// }
//// ```
////
//// For a more complete example, see the [`page module`](https://hexdocs.pm/butterbee/page-modules) guide.

import butterbee/get
import butterbee/webdriver.{type WebDriver}
import butterbidi/browsing_context/types/locator.{type Locator}

pub type NodeTable {
  Table
  Row(Int)
  Cell(row: Int, column: Int)
}

pub fn define(
  table table_locator: Locator,
  table_row table_row_locator: Locator,
  table_cell table_cell_locator: Locator,
  table_width table_width: Int,
) -> #(Locator, Locator, Locator, Int) {
  #(table_locator, table_row_locator, table_cell_locator, table_width)
}

pub fn perform_action(
  locator: #(Locator, Locator, Locator, Int),
  driver: WebDriver(state),
  on_element: NodeTable,
  action: fn(_) -> WebDriver(new_state),
) -> WebDriver(new_state) {
  let #(table_locator, table_row_locator, table_cell_locator, table_width) =
    locator

  case on_element {
    Table -> get.node(driver, table_locator)
    Row(row) -> {
      driver
      |> get.node(table_locator)
      |> get.nodes_from_node(table_row_locator)
      |> get.node_from_nodes(row)
    }
    Cell(row, column) -> {
      // Kind of hacky way to get the cell index.
      // Specifying from start nodes does not work because the start node
      // still includes the nodes around it, e.g. specifying from row 1 will
      // will also find the cells from row 2, row 3, etc.
      let cell = row * table_width + column
      driver
      |> get.node(table_locator)
      |> get.nodes_from_node(table_cell_locator)
      |> get.node_from_nodes(cell)
    }
  }
  |> action
}
