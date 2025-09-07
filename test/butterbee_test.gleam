import butterbee
import butterbee/by
import butterbee/driver
import butterbee/key
import butterbee/nodes
import gleam/erlang/process
import gleam/list
import gleam/string
import gleeunit

import butterbee/input
import butterbee/query
import logging

pub fn main() {
  logging.configure()
  logging.set_level(logging.Debug)
  butterbee.init()
  gleeunit.main()
  echo "Done"
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

pub fn enter_keys_test() {
  let package_names =
    driver.new()
    |> driver.goto("https://packages.gleam.run/")
    |> query.node(by.xpath("//input[@name='search']"))
    |> input.enter_keys("stdlib" <> key.enter())
    |> driver.wait(200)
    |> query.nodes(by.css("div.package-item"))
    |> query.refine(by.css("h2.package-name"))
    |> nodes.inner_texts()
    |> driver.close()

  let trimmed_package_names =
    package_names
    |> list.map(fn(package_name) {
      let assert Ok(p) = string.split(package_name, "@") |> list.first()
        as "No package name found"
      p
    })

  echo trimmed_package_names

  assert trimmed_package_names |> list.contains("gleam_stdlib")
}

pub fn code_comment_driver_wait_test() {
  let example =
    driver.new()
    |> driver.wait(2000)
    |> driver.goto("https://gleam.run/")
    |> driver.get_url()
    |> driver.close()
  assert example == "https://gleam.run/"
}

pub fn code_comment_driver_close_test() {
  let example =
    driver.new()
    |> driver.goto("https://gleam.run/")
    |> query.node(by.css("a.logo"))
    |> nodes.inner_text()
    |> driver.close()
  assert example == "Gleam"
}
