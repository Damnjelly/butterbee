//// Define elements for page module using this module.
////
//// Example:
////
//// ```gleam
//// import butterbee
//// import butterbee/by
//// import butterbee/element.{type NodeList, type NodeTable}
//// import butterbee/webdriver.{type WebDriver}
////
//// pub fn submit_button(
////   driver: WebDriver(state),
////   action: fn(_) -> WebDriver(new_state),
//// ) {
////   element.define(field: by.css("button#submit"))
////   |> element.perform(driver, action)
//// }
////
//// pub fn team_list(
////   driver: WebDriver(state),
////   on_element: NodeList,
////   action: fn(_) -> WebDriver(new_state),
//// ) {
////   element.define_list(
////     list: by.css("ul#team"),
////     list_item: by.css("li"),
////   )
////   |> element.perform_on_list(driver, on_element, action)
//// }
////
//// pub fn pokemon_dropdown(
////   driver: WebDriver(state),
////   action: fn(_) -> WebDriver(new_state),
//// ) {
////   element.define(field: by.css("select#pokemon"))
////   |> element.perform_action(driver, action)
//// }
////
//// pub fn pokedex_table(
////   driver: WebDriver(state),
////   on_element: NodeTable,
////   action: fn(_) -> WebDriver(new_state),
//// ) {
////   element.define_table(
////     table: by.css("table#pokedex"),
////     table_row: by.css("tr"),
////     table_cell: by.css("td"),
////     table_width: 3,
////   )
////   |> element.perform_on_table(driver, on_element, action)
//// }
//// ```
////
//// For a more complete example, see the [`page module`](https://hexdocs.pm/butterbee/page-modules.html) guide.

import butterbee/get
import butterbee/webdriver.{type WebDriver}
import butterbidi/browsing_context/types/locator.{type Locator}

pub type NodeList {
  List
  Item(Int)
}

pub type NodeTable {
  Table
  Row(Int)
  Cell(row: Int, column: Int)
}

/// Define an element for a page module.
pub fn define(field locator: Locator) -> Locator {
  locator
}

/// Define a list for a page module.
pub fn define_list(
  list list_locator: Locator,
  list_item list_item_locator: Locator,
) -> #(Locator, Locator) {
  #(list_locator, list_item_locator)
}

/// Define a table for a page module.
pub fn define_table(
  table table_locator: Locator,
  table_row table_row_locator: Locator,
  table_cell table_cell_locator: Locator,
  table_width table_width: Int,
) -> #(Locator, Locator, Locator, Int) {
  #(table_locator, table_row_locator, table_cell_locator, table_width)
}

/// Perform an action on the defined element.
pub fn perform(
  locator: Locator,
  driver: WebDriver(state),
  action: fn(_) -> WebDriver(new_state),
) -> WebDriver(new_state) {
  get.node(driver, locator)
  |> action
}

/// Perform an action on the defined list.
pub fn perform_on_list(
  locator: #(Locator, Locator),
  driver: WebDriver(state),
  on_element: NodeList,
  action: fn(_) -> WebDriver(new_state),
) -> WebDriver(new_state) {
  let #(list_locator, list_item_locator) = locator

  case on_element {
    List -> get.node(driver, list_locator)
    Item(row) -> {
      driver
      |> get.node(list_locator)
      |> get.nodes_from_node(list_item_locator)
      |> get.node_from_nodes(row)
    }
  }
  |> action
}

/// Perform an action on the defined table.
pub fn perform_on_table(
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
