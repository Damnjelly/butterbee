# butterbee


[![Package Version](https://img.shields.io/hexpm/v/butterbee)](https://hex.pm/packages/butterbee)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/butterbee/)

### Control the browser with gleam code using butterbee!

Butterbee is a webdriver bidi cilent written in Gleam, for Gleam.
It provides both a simple API for interacting with a webdriver server, 
and a more complex API for interacting with the webdriver bidi protocol directly.

WARNING: Butterbee is still in early development and incomplete. Butterbee only supports Firefox at the moment, and the API is subject to change.

NOTE: Because of test runner limitations, butterbee does not close the browser automatically when the test panics. If tests start randomly failing, check for any open browser processes in your system manager.

```sh
gleam add --dev butterbee
```

### Example

Getting started with butterbee is easy! make sure Firefox is on your $PATH, add the code below to your test and run `gleam test`.

```gleam
import butterbee
import butterbee/by
import butterbee/config/browser
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
```

### Guides

- [Butterbee configuration](https://hexdocs.pm/butterbee/config)
- [Other testrunners](https://hexdocs.pm/butterbee/test-runners)
- [Github actions](https://hexdocs.pm/butterbee/github-actions)


## Development

### Roadmap

- [ ] Support for chromium 
- [ ] Add more webdriver bidi commands
