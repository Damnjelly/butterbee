import argv
import butterbee
import butterbee/action
import butterbee/by
import butterbee/config/browser
import butterbee/driver
import butterbee/get
import butterbee/key
import butterbee/node
import butterlib/log
import gleeunit
import logging
import pprint.{BitArraysAsString, Config, NoLabels, Styled}
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
  let assert Ok(output) =
    driver.new(browser.Firefox)
    |> driver.goto("https://gleam.run/")
    |> get.node(by.xpath(
      "//div[@class='hero']//a[@href='https://tour.gleam.run/']",
    ))
    |> node.do(action.click(key.LeftClick))
    |> get.node(by.css("pre.log"))
    |> node.get(node.any_text())
    |> driver.close()
  assert output == "Hello, Joe!\n"
}

pub fn pretty_print(value: a) -> String {
  value
  |> pprint.with_config(Config(
    style_mode: Styled,
    bit_array_mode: BitArraysAsString,
    label_mode: NoLabels,
  ))
}
