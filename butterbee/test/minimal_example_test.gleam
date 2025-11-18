//// Tests the minimal example to ensure it works as is.
//// Keep README.md up to date with this test

import butterbee
import butterbee/action
import butterbee/by
import butterbee/config
import butterbee/get
import butterbee/key
import butterbee/node
import gleeunit

pub fn main() {
  butterbee.init()
  gleeunit.main()
}

pub type Timeout {
  Timeout(Float, fn() -> Nil)
}

pub fn minimal_example_test_() {
  use <- Timeout(30.0)

  use driver <- butterbee.run([config.Firefox])
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
