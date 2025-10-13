import argv
import butterbee
import butterbee/by
import butterbee/config/browser
import butterbee/input
import butterbee/nodes
import butterbee/query
import butterbee/webdriver
import butterlib/log
import gleeunit
import logging
import pprint.{BitArraysAsString, Config, Labels, Styled}
import qcheck_gleeunit_utils/test_spec

pub const timeout = 30

pub fn main() {
  let _ = case argv.load().arguments {
    ["--debug"] -> {
      log.configure(logging.Debug)
    }
    _ -> log.configure(logging.Error)
  }
  butterbee.init()
  gleeunit.main()
}

pub fn minimal_example_test_() {
  use <- test_spec.make_with_timeout(timeout)
  let output =
    webdriver.new(browser.Firefox)
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

///
/// Pretty prints a value using the pprint library
///
pub fn pretty_print(value: a) -> String {
  value
  |> pprint.with_config(Config(
    style_mode: Styled,
    bit_array_mode: BitArraysAsString,
    label_mode: Labels,
  ))
}
