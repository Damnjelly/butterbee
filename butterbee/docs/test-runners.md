To set a timeout for your tests in gleeunit, you can create a `Timeout` type and use it in your test like this:

```gleam
import butterbee
import butterbee/action
import butterbee/by
import butterbee/config.{Firefox}
import butterbee/get
import butterbee/key
import butterbee/node
import gleeunit

pub const timeout = 30.0

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


you can also use [qcheck_gleeunit_utils](https://hexdocs.pm/qcheck_gleeunit_utils/index.html) to run your tests. Since it allows you to set a timeout for your tests.

The 'getting started' would look something like this with qcheck_gleeunit_utils integration:

```gleam
import butterbee
import butterbee/action
import butterbee/by
import butterbee/config.{Firefox}
import butterbee/get
import butterbee/key
import butterbee/node
import gleeunit
import qcheck_gleeunit_utils/test_spec

pub const timeout = 30

pub fn minimal_example_test_() {
  use <- test_spec.make_with_timeout(timeout)
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
