import butterbee
import butterbee/action
import butterbee/config.{Firefox}
import butterbee/element.{Cell, Item, Row}
import butterbee/internal/test_page
import butterbee/key
import butterbee/node
import butterbee_test.{timeout}
import gleam/string

pub fn navigation_test_() {
  use <- butterbee_test.Timeout(timeout)

  use driver <- butterbee.run(Firefox)
  let assert Ok(first_url) =
    driver
    |> butterbee.url()
    |> butterbee.value()
  assert True == string.contains(first_url, "about:blank")

  let assert Ok(second_url) =
    driver
    |> test_page.goto()
    |> butterbee.url()
    |> butterbee.value()
  assert True == string.ends_with(second_url, "test_page.html")
}

pub fn enter_keys_test_() {
  use <- butterbee_test.Timeout(timeout)

  use driver <- butterbee.run(Firefox)
  let comment =
    driver
    |> test_page.goto()
    |> test_page.comments_field(node.set_value("line1\nline2\n"))
    |> test_page.comments_field(node.text())
    |> butterbee.value()
  assert comment == Ok("line1\nline2\n")
}

pub fn select_navigation_test_() {
  use <- butterbee_test.Timeout(timeout)

  use driver <- butterbee.run(Firefox)
  let country =
    driver
    |> test_page.goto()
    |> test_page.country_dropdown(node.select_option("Canada"))
    |> test_page.country_dropdown(node.selected_text())
    |> butterbee.value()
  assert country == Ok("Canada")
}

pub fn select_key_navigation_test_() {
  use <- butterbee_test.Timeout(timeout)

  use driver <- butterbee.run(Firefox)
  let country =
    driver
    |> test_page.goto()
    |> test_page.country_dropdown(action.click(key.LeftClick))
    |> test_page.country_dropdown(action.enter_keys(key.arrow_down))
    |> test_page.country_dropdown(action.enter_keys(key.enter))
    |> test_page.country_dropdown(node.selected_text())
    |> butterbee.value()
  assert country == Ok("United States")
}

pub fn button_test_() {
  use <- butterbee_test.Timeout(timeout)

  use driver <- butterbee.run(Firefox)
  let has_style =
    driver
    |> test_page.goto()
    |> test_page.change_color_button(action.click(key.LeftClick))
    |> test_page.body(node.has_attribute("style"))
    |> butterbee.value()
  assert has_style == Ok(True)
}

pub fn table_test_() {
  use <- butterbee_test.Timeout(timeout)

  use driver <- butterbee.run(Firefox)
  let table =
    driver
    |> test_page.goto()
    |> test_page.data_table(element.Table, node.inner_text())
    |> butterbee.value()
  assert table
    == Ok(
      "ID\tName\tStatus\n1\tTest Item 1\tPASS\n2\tTest Item 2\tFAIL\n3\tTest Item 3\tPASS",
    )
}

pub fn table_row_test_() {
  use <- butterbee_test.Timeout(timeout)

  use driver <- butterbee.run(Firefox)
  let driver =
    driver
    |> test_page.goto()

  let table_row =
    driver
    |> test_page.data_table(Row(0), node.inner_text())
    |> butterbee.value()
  assert table_row == Ok("ID\tName\tStatus")

  let table_row =
    driver
    |> test_page.data_table(Row(1), node.inner_text())
    |> butterbee.value()
  assert table_row == Ok("1\tTest Item 1\tPASS")
}

pub fn table_cell_test_() {
  use <- butterbee_test.Timeout(timeout)

  use driver <- butterbee.run(Firefox)
  let driver =
    driver
    |> test_page.goto()
  let assert Ok(cell_1_1) =
    driver
    |> test_page.data_table(Cell(0, 0), node.inner_text())
    |> butterbee.value()
  let assert Ok(cell_1_2) =
    driver
    |> test_page.data_table(Cell(0, 1), node.inner_text())
    |> butterbee.value()
  let assert Ok(cell_1_3) =
    driver
    |> test_page.data_table(Cell(0, 2), node.inner_text())
    |> butterbee.value()
  let assert Ok(cell_2_1) =
    driver
    |> test_page.data_table(Cell(1, 0), node.inner_text())
    |> butterbee.value()
  let assert Ok(cell_2_2) =
    driver
    |> test_page.data_table(Cell(1, 1), node.inner_text())
    |> butterbee.value()
  let assert Ok(cell_2_3) =
    driver
    |> test_page.data_table(Cell(1, 2), node.inner_text())
    |> butterbee.value()
  let assert Ok(cell_3_1) =
    driver
    |> test_page.data_table(Cell(2, 0), node.inner_text())
    |> butterbee.value()
  let assert Ok(cell_3_2) =
    driver
    |> test_page.data_table(Cell(2, 1), node.inner_text())
    |> butterbee.value()
  let assert Ok(cell_3_3) =
    driver
    |> test_page.data_table(Cell(2, 2), node.inner_text())
    |> butterbee.value()
  assert cell_1_1 <> " " <> cell_1_2 <> " " <> cell_1_3 == "1 Test Item 1 PASS"
  assert cell_2_1 <> " " <> cell_2_2 <> " " <> cell_2_3 == "2 Test Item 2 FAIL"
  assert cell_3_1 <> " " <> cell_3_2 <> " " <> cell_3_3 == "3 Test Item 3 PASS"
}

pub fn list_test_() {
  use <- butterbee_test.Timeout(timeout)

  use driver <- butterbee.run(Firefox)
  let list =
    driver
    |> test_page.goto()
    |> test_page.test_list(element.List, node.inner_text())
    |> butterbee.value()
  assert list
    == Ok(
      "First List Item\nSecond List Item\nThird List Item\nFourth List Item\nFifth List Item",
    )
}

pub fn list_item_test_() {
  use <- butterbee_test.Timeout(timeout)

  use driver <- butterbee.run(Firefox)
  let driver =
    driver
    |> test_page.goto()

  let list_item =
    driver
    |> test_page.test_list(Item(0), node.inner_text())
    |> butterbee.value()
  assert list_item == Ok("First List Item")

  let list_item =
    driver
    |> test_page.test_list(Item(1), node.inner_text())
    |> butterbee.value()
  assert list_item == Ok("Second List Item")

  let list_item =
    driver
    |> test_page.test_list(Item(2), node.inner_text())
    |> butterbee.value()
  assert list_item == Ok("Third List Item")

  let list_item =
    driver
    |> test_page.test_list(Item(3), node.inner_text())
    |> butterbee.value()
  assert list_item == Ok("Fourth List Item")

  let list_item =
    driver
    |> test_page.test_list(Item(4), node.inner_text())
    |> butterbee.value()
  assert list_item == Ok("Fifth List Item")
}
