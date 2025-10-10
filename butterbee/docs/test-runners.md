Gleeunit, currently, it has an unconfigurable timeout time. Which is a problem for 
running browser based tests, since they tend to take longer than the timeout permits.

For browser tests I currently recommend using [qcheck_gleeunit_utils](https://hexdocs.pm/qcheck_gleeunit_utils/index.html) to run your tests. Since it allows you to set a timeout for your tests.

The 'getting started' would look something like this with qcheck_gleeunit_utils integration:

```gleam
import butterbee
import butterbee/by
import butterbee/config/browser
import butterbee/input
import butterbee/nodes
import butterbee/query
import butterbee/webdriver
import gleeunit
import qcheck_gleeunit_utils/test_spec

pub fn minimal_example_test_() {
  use <- test_spec.make_with_timeout(30)
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
