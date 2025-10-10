import butterbee/config/browser_config.{Firefox}
import butterbee/page
import butterbee/webdriver
import qcheck_gleeunit_utils/test_spec

pub fn wait_test_() {
  use <- test_spec.make_with_timeout(30)
  let driver = webdriver.new(Firefox)

  let first_url =
    page.url(driver)
    |> webdriver.wait(1000)
    |> webdriver.value

  let second_url =
    webdriver.goto(driver, "https://gleam.run/")
    |> page.url()
    |> webdriver.close()

  assert #(first_url, second_url) == #("about:blank", "https://gleam.run/")
}
