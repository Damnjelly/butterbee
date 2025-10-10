# butterbee


[![Package Version](https://img.shields.io/hexpm/v/butterbee)](https://hex.pm/packages/butterbee)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/butterbee/)

Butterbee is a webdriver bidi cilent written in Gleam, for Gleam.
It provides both a simple API for interacting with a webdriver server, 
and a more complex API for interacting with the webdriver bidi protocol directly.

WARNING: butterbee is still in early development and incomplete. Butterbee only supports Firefox at the moment, and the API is subject to change.

```sh
gleam add butterbee
```

### Example

Getting started with butterbee is easy, make sure Firefox is on your $PATH, and run the following:

```gleam
import butterbee
import butterbee/by
import butterbee/config/browser_config
import butterbee/input
import butterbee/nodes
import butterbee/query
import butterbee/webdriver
import gleeunit

pub fn main() {
  butterbee.init()
  gleeunit.main()
}

pub fn minimal_example_test_() {
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
```

### Guides

- [butterbee configuration](https://hexdocs.pm/butterbee/config)
- [other testrunners](https://hexdocs.pm/butterbee/test-runners)
- [webdriver bidi protocol documentation](https://w3c.github.io/webdriver-bidi/)


## Development

### Upcoming features

- [ ] Support for Chrome
- [ ] Support for more webdriver bidi commands
- [ ] Running tests in parallel

### Contributing
