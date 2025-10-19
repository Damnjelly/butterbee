import butterbee/config/browser.{Firefox}
import butterbee/driver
import butterbee/page
import butterbee_test
import gleam/string
import qcheck_gleeunit_utils/test_spec

// pub fn enter_keys_test_() {
//   use <- test_spec.make_with_timeout(butterbee_test.timeout)
//
//   let comments =
//     butterbee_test.test_page(Firefox)
//     |> test_page.comments_field()
//     |> input.enter_keys("line1" <> key.enter <> "line2" <> key.enter)
//     |> test_page.comments_field()
//     |> nodes.inner_text()
//     |> webdriver.close()
//
//   assert comments == "line1\nline2\n"
// }

pub fn navigation_test_() {
  use <- test_spec.make_with_timeout(butterbee_test.timeout)
  let driver = butterbee_test.test_page(Firefox)

  let assert Ok(first_url) =
    page.url(driver)
    |> driver.wait(1000)
    |> driver.value()
  assert True == string.ends_with(first_url, "test_page.html")

  let assert Ok(second_url) =
    driver.goto(driver, "about:blank")
    |> page.url()
    |> driver.close()
  assert True == string.contains(second_url, "about:blank")
}
