import butterbee/by
import butterbee/driver
import butterbee/node
import gleam/erlang/process
import gleeunit

import butterbee/input
import butterbee/query
import logging

pub fn main() {
  logging.configure()
  logging.set_level(logging.Debug)
  process.sleep(1000)
  gleeunit.main()
}

pub fn minimal_example_test() {
  let text =
    driver.new()
    |> driver.goto("https://gleam.run/")
    |> query.node(by.xpath(
      "//div[@class='hero']//a[@href='https://tour.gleam.run/']",
    ))
    |> input.click()
    |> query.node(by.css("pre.log"))
    |> node.inner_text()
    |> driver.end()
  assert text == "Hello, Joe!\n"
}

pub fn timout_test() {
  let _ =
    driver.new()
    |> driver.goto("https://gleam.run/")
    |> query.node(by.css("pre.log"))
}
