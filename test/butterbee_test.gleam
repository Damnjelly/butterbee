import butterbee
import butterbee/by
import butterbee/driver
import butterbee/nodes
import gleeunit
import logging

import butterbee/input
import butterbee/query

pub fn main() {
  // logging.configure()
  // logging.set_level(logging.Info)
  butterbee.init()
  gleeunit.main()
}

pub fn minimal_example_test() {
  let output =
    driver.new()
    |> driver.goto("https://gleam.run/")
    |> query.node(by.xpath(
      "//div[@class='hero']//a[@href='https://tour.gleam.run/']",
    ))
    |> input.click()
    |> query.node(by.css("pre.log"))
    |> nodes.inner_text()
    |> driver.close()
  assert output == "Hello, Joe!\n"
}
