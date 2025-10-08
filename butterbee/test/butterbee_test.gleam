import argv
import butterbee
import butterbee/by
import butterbee/nodes
import butterbee/webdriver
import gleeunit
import logging
import qcheck_gleeunit_utils/test_spec

import butterbee/input
import butterbee/query

pub fn main() {
  case argv.load().arguments {
    ["--debug"] -> {
      logging.configure()
      logging.set_level(logging.Debug)
    }
    _ -> Nil
  }

  butterbee.init()
  gleeunit.main()
}

pub fn minimal_example_test_() {
  use <- test_spec.make_with_timeout(30)
  let output =
    webdriver.new()
    |> webdriver.goto("https://gleam.run/")
    |> query.node(by.xpath(
      "//div[@class='hero']//a[@href='https://tour.gleam.run/']",
    ))
    |> input.click(input.LeftClick)
    |> webdriver.wait(10_000)
    |> query.node(by.css("pre.log"))
    |> nodes.inner_text()
    |> webdriver.close()
  assert output == "Hello, Joe!\n"
}
