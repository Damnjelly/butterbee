# butterbee

[![Package Version](https://img.shields.io/hexpm/v/butterbee)](https://hex.pm/packages/butterbee)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/butterbee/)

```sh
gleam add butterbee@1
```
```gleam
import butterbee
import butterbee/by
import butterbee/driver
import butterbee/nodes
import gleeunit

import butterbee/input
import butterbee/query
import logging

pub fn main() {
  logging.configure()
  logging.set_level(logging.Debug)
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
```

Further documentation can be found at <https://hexdocs.pm/butterbee>.

## Development

```sh
gleam run   # Run the project
gleam test  # Run the tests
```
