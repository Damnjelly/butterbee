import butterbee/action
import butterbee/config/browser.{Firefox}
import butterbee/driver
import butterbee/internal/test_page
import butterbee/key
import butterbee/node
import butterbee/page
import butterbee/page_module/node_select
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
