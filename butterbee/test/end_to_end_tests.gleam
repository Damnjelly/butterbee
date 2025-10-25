import butterbee/action
import butterbee/config/browser.{Firefox}
import butterbee/driver
import butterbee/internal/test_page
import butterbee/key
import butterbee/node
import butterbee/page
import butterbee/page_module/node_list
import butterbee/page_module/node_select
import butterbee/page_module/node_table
import butterbee_test
import gleam/string
import qcheck_gleeunit_utils/test_spec

pub fn navigation_test_() {
  use <- test_spec.make_with_timeout(butterbee_test.timeout)
  let driver = driver.new(Firefox)

  let assert Ok(first_url) =
    driver
    |> page.url()
    |> driver.value()
  assert True == string.contains(first_url, "about:blank")

  let assert Ok(second_url) =
    driver
    |> test_page.goto()
    |> page.url()
    |> driver.close()
  assert True == string.ends_with(second_url, "test_page.html")
}

pub fn enter_keys_test_() {
  use <- test_spec.make_with_timeout(butterbee_test.timeout)

  let driver = driver.new(Firefox)
  let assert Ok(comment) =
    driver
    |> test_page.goto()
    |> test_page.comments_field(node.set_value("line1\nline2\n"))
    |> test_page.comments_field(node.text())
    |> driver.close()
  assert comment == "line1\nline2\n"
}

pub fn select_navigation_test_() {
  use <- test_spec.make_with_timeout(butterbee_test.timeout)

  let assert Ok(country) =
    driver.new(Firefox)
    |> test_page.goto()
    |> test_page.country_dropdown(node_select.option("Canada"))
    |> test_page.country_dropdown(node_select.selected_text())
    |> driver.close()
  assert country == "Canada"
}

pub fn select_key_navigation_test_() {
  use <- test_spec.make_with_timeout(butterbee_test.timeout)

  let assert Ok(country) =
    driver.new(Firefox)
    |> test_page.goto()
    |> test_page.country_dropdown(action.click(key.LeftClick))
    |> test_page.country_dropdown(action.enter_keys(key.arrow_down))
    |> test_page.country_dropdown(action.enter_keys(key.enter))
    |> test_page.country_dropdown(node_select.selected_text())
    |> driver.close()
  assert country == "United States"
}

pub fn button_test_() {
  use <- test_spec.make_with_timeout(butterbee_test.timeout)

  let assert Ok(has_style) =
    driver.new(Firefox)
    |> test_page.goto()
    |> test_page.change_color_button(action.click(key.LeftClick))
    |> test_page.body(node.has_attribute("style"))
    |> driver.close()
  assert has_style == True
}

pub fn table_test_() {
  use <- test_spec.make_with_timeout(butterbee_test.timeout)

  let assert Ok(table) =
    driver.new(Firefox)
    |> test_page.goto()
    |> test_page.data_table(node_table.Table, node.inner_text())
    |> driver.close()
  assert table
    == "ID\tName\tStatus\n1\tTest Item 1\tPASS\n2\tTest Item 2\tFAIL\n3\tTest Item 3\tPASS"
}

pub fn table_row_test_() {
  use <- test_spec.make_with_timeout(butterbee_test.timeout)

  let driver =
    driver.new(Firefox)
    |> test_page.goto()

  let assert Ok(table_row) =
    driver
    |> test_page.data_table(node_table.Row(0), node.inner_text())
    |> driver.value()
  assert table_row == "ID\tName\tStatus"

  let assert Ok(table_row) =
    driver
    |> test_page.data_table(node_table.Row(1), node.inner_text())
    |> driver.value()
  assert table_row == "1\tTest Item 1\tPASS"
}

pub fn table_cell_test_() {
  use <- test_spec.make_with_timeout(butterbee_test.timeout)

  let driver =
    driver.new(Firefox)
    |> test_page.goto()
  let assert Ok(cell_1_1) =
    driver
    |> test_page.data_table(node_table.Cell(0, 0), node.inner_text())
    |> driver.value()
  let assert Ok(cell_1_2) =
    driver
    |> test_page.data_table(node_table.Cell(0, 1), node.inner_text())
    |> driver.value()
  let assert Ok(cell_1_3) =
    driver
    |> test_page.data_table(node_table.Cell(0, 2), node.inner_text())
    |> driver.value()
  let assert Ok(cell_2_1) =
    driver
    |> test_page.data_table(node_table.Cell(1, 0), node.inner_text())
    |> driver.value()
  let assert Ok(cell_2_2) =
    driver
    |> test_page.data_table(node_table.Cell(1, 1), node.inner_text())
    |> driver.value()
  let assert Ok(cell_2_3) =
    driver
    |> test_page.data_table(node_table.Cell(1, 2), node.inner_text())
    |> driver.value()
  let assert Ok(cell_3_1) =
    driver
    |> test_page.data_table(node_table.Cell(2, 0), node.inner_text())
    |> driver.value()
  let assert Ok(cell_3_2) =
    driver
    |> test_page.data_table(node_table.Cell(2, 1), node.inner_text())
    |> driver.value()
  let assert Ok(cell_3_3) =
    driver
    |> test_page.data_table(node_table.Cell(2, 2), node.inner_text())
    |> driver.value()
  assert cell_1_1 <> " " <> cell_1_2 <> " " <> cell_1_3 == "1 Test Item 1 PASS"
  assert cell_2_1 <> " " <> cell_2_2 <> " " <> cell_2_3 == "2 Test Item 2 FAIL"
  assert cell_3_1 <> " " <> cell_3_2 <> " " <> cell_3_3 == "3 Test Item 3 PASS"
}

pub fn list_test_() {
  use <- test_spec.make_with_timeout(butterbee_test.timeout)

  let assert Ok(list) =
    driver.new(Firefox)
    |> test_page.goto()
    |> test_page.test_list(node_list.List, node.inner_text())
    |> driver.close()
  assert list
    == "First List Item\nSecond List Item\nThird List Item\nFourth List Item\nFifth List Item"
}

pub fn list_item_test_() {
  use <- test_spec.make_with_timeout(butterbee_test.timeout)

  let driver =
    driver.new(Firefox)
    |> test_page.goto()

  let assert Ok(list_item) =
    driver
    |> test_page.test_list(node_list.Row(0), node.inner_text())
    |> driver.value()
  assert list_item == "First List Item"

  let assert Ok(list_item) =
    driver
    |> test_page.test_list(node_list.Row(1), node.inner_text())
    |> driver.value()
  assert list_item == "Second List Item"

  let assert Ok(list_item) =
    driver
    |> test_page.test_list(node_list.Row(2), node.inner_text())
    |> driver.value()
  assert list_item == "Third List Item"

  let assert Ok(list_item) =
    driver
    |> test_page.test_list(node_list.Row(3), node.inner_text())
    |> driver.value()
  assert list_item == "Fourth List Item"

  let assert Ok(list_item) =
    driver
    |> test_page.test_list(node_list.Row(4), node.inner_text())
    |> driver.close()
  assert list_item == "Fifth List Item"
}
