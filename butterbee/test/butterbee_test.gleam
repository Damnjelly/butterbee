import argv
import butterbee
import butterbee/by
import butterbee/config/browser_config
import butterbee/input
import butterbee/internal/log
import butterbee/nodes
import butterbee/query
import butterbee/webdriver
import gleeunit
import logging
import qcheck_gleeunit_utils/test_spec

pub fn main() {
  logging.configure()
  case argv.load().arguments {
    ["--debug"] -> {
      log.configure(logging.Debug)
    }
    _ -> log.configure(logging.Info)
  }

  butterbee.init()
  gleeunit.main()
}

pub fn minimal_example_test_() {
  use <- test_spec.make_with_timeout(30)
  let output =
    webdriver.new(browser_config.Firefox)
    |> webdriver.goto("https://gleam.run/")
    |> query.node(by.xpath(
      "//div[@class='hero']//a[@href='https://tour.gleam.run/']",
    ))
    |> input.click(input.LeftClick)
    |> query.node(by.css("pre.log"))
    |> nodes.inner_text()
    |> webdriver.close()
  assert output == "Hello, Joe!\n"
}
