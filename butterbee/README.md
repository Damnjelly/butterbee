# butterbee


[![Package Version](https://img.shields.io/hexpm/v/butterbee)](https://hex.pm/packages/butterbee)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/butterbee/)

### Control the browser with gleam code using butterbee!

Butterbee is a webdriver bidi client written in Gleam. 
Webdriver bidi is a protocol that allows for controlling the browser via code. 
It's primary usage is to write tests that automate user behavior on a web page

## Getting started

```sh
gleam add --dev butterbee
```

### Example

Getting started with butterbee is easy! make sure Firefox is on your $PATH, add the code below to your test and run `gleam test`.

```gleam
import butterbee
import butterbee/action
import butterbee/by
import butterbee/config.{Firefox}
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
```

NOTE: Because of test runner limitations, butterbee does not close the browser automatically when the test panics. If tests start randomly failing, check for any open browser processes in your system manager.

### Guides

- [Butterbee configuration](https://hexdocs.pm/butterbee/butterbee/config.html)
- [Page modules](https://hexdocs.pm/butterbee/page-modules.html)
- [Other testrunners](https://hexdocs.pm/butterbee/test-runners.html)
- [Github actions](https://hexdocs.pm/butterbee/github-actions.html)

