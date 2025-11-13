import argv
import butterbee
import butterbee/action
import butterbee/by
import butterbee/config.{Firefox}
import butterbee/get
import butterbee/internal/log
import butterbee/key
import butterbee/node
import gleeunit
import palabres/level
import pprint.{BitArraysAsString, Config, NoLabels, Styled}

pub const timeout = 30.0

fn load_arguments() {
  case argv.load().arguments {
    ["--debug"] -> {
      log.configure(level.Debug)
    }
    _ -> log.configure(level.Warning)
  }
}

pub fn main() {
  load_arguments()
  butterbee.init()
  gleeunit.main()
}

pub type Timeout {
  Timeout(Float, fn() -> Nil)
}

pub fn minimal_example_test_() {
  use <- Timeout(timeout)

  use driver <- butterbee.run(Firefox)
  let output =
    driver
    |> butterbee.goto("https://gleam.run/")
    |> get.node(by.xpath(
      "//div[@class='hero']//a[@href='https://tour.gleam.run/']",
    ))
    |> node.do(action.click(key.LeftClick))
    |> get.node(by.css("pre.log"))
    |> node.get(node.text())
    |> butterbee.value()
  assert output == Ok("Hello, Joe!\n")
}

pub fn pretty_print(value: a) -> String {
  value
  |> pprint.with_config(Config(
    style_mode: Styled,
    bit_array_mode: BitArraysAsString,
    label_mode: NoLabels,
  ))
}
