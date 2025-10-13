import butterbee/by
import butterbee/config/browser.{Firefox}
import butterbee/key
import butterbee/nodes
import butterbee/page
import butterbee/webdriver
import butterbee_test
import gleam/list
import gleam/string
import qcheck_gleeunit_utils/test_spec

import butterbee/input
import butterbee/query

pub fn enter_keys_test_() {
  use <- test_spec.make_with_timeout(butterbee_test.timeout)
  let package_names =
    webdriver.new(Firefox)
    |> webdriver.goto("https://packages.gleam.run/")
    |> query.node(by.xpath("//input[@name='search']"))
    |> input.enter_keys("stdlib" <> key.enter())
    |> webdriver.wait(200)
    |> query.nodes(by.css("div.package-item"))
    |> query.refine(by.css("h2.package-name"))
    |> nodes.inner_texts()
    |> webdriver.close()

  let trimmed_package_names =
    package_names
    |> list.map(fn(package_name) {
      let assert Ok(p) = string.split(package_name, "@") |> list.first()
        as "No package name found"
      p
    })

  assert trimmed_package_names |> list.contains("gleam_stdlib")
}

pub fn wait_test_() {
  use <- test_spec.make_with_timeout(butterbee_test.timeout)
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
