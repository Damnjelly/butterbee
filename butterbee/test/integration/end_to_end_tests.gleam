import butterbee/by
import butterbee/key
import butterbee/nodes
import butterbee/webdriver
import gleam/list
import gleam/string
import qcheck_gleeunit_utils/test_spec

import butterbee/input
import butterbee/query

pub fn enter_keys_test_() {
  use <- test_spec.make_with_timeout(30)
  let package_names =
    webdriver.new()
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
