import butterbee/action
import butterbee/config/browser.{Firefox}
import butterbee/driver
import butterbee/internal/test_page
import butterbee/key
import butterbee/node
import butterbee/page
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

  let assert Ok(comment) =
    driver.new(Firefox)
    |> test_page.goto()
    |> test_page.comments_field(action.enter_keys(
      "line1" <> key.enter <> "line2" <> key.enter,
    ))
    |> test_page.comments_field(node.any_text())
    |> driver.close()
  assert comment == "line1\nline2\n"
}
//
// pub fn button_test_() {
//   use <- test_spec.make_with_timeout(butterbee_test.timeout)
//
//   let assert Ok(first_color) =
//     driver.new(Firefox)
//     |> test_page.submit_form_button(action.click(key.LeftClick))
//     |> test_page.submit_form_button(node.inner_text())
//     |> driver.close()
//
//   let assert Ok(button) =
//     driver.new(Firefox)
//     |> test_page.change_color_button(action.click(key.LeftClick))
//     |> driver.close()
//   assert button == "Submit"
// }
//
// pub fn dropdown_test_() {
//   use <- test_spec.make_with_timeout(butterbee_test.timeout)
//
//   let assert Ok(country) =
//     driver.new(Firefox)
//     |> test_page.country_dropdown(action.click(key.DownArrow))
//     |> test_page.country_dropdown(node.inner_text())
//     |> driver.close()
//   assert country == "Canada"
// }
