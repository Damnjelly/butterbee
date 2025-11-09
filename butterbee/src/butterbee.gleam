import butterbee/action
import butterbee/by
import butterbee/config/browser
import butterbee/driver
import butterbee/get
import butterbee/key
import butterbee/node
import butterlib/log
import palabres as logger
import simplifile

/// Initialize butterbee,
/// Call this in the main function of your test, before calling gleeunit.main.
/// Then call [`driver.new`](https://hexdocs.pm/butterbee/driver.html#new) in your test
/// to start using butterbee.
pub fn init() {
  logger.debug("Initializing butterbee")
  |> logger.log
  logger.debug("Deleting data_dir")
  |> logger.log
  //TODO: actually delete data_dir instead of hardcoding it
  // let _ = simplifile.delete("/tmp/butterbee")

  Nil
}

pub fn main() {
  let assert Ok(output) =
    driver.new(browser.Chromium)
    |> driver.goto("https://gleam.run/")
    |> get.node(by.xpath(
      "//div[@class='hero']//a[@href='https://tour.gleam.run/']",
    ))
    |> node.do(action.click(key.LeftClick))
    |> get.node(by.css("pre.log"))
    |> node.get(node.text())
    |> driver.close()
  assert output == "Hello, Joe!\n"
}
