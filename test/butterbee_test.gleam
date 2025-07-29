import butterbee/driver
import butterbee/internal/bidi/browsing_context
import butterbee/internal/bidi/input
import butterbee/internal/bidi/script
import gleam/erlang/process
import gleam/list
import gleam/option.{None, Some}
import logging
import youid/uuid

pub fn main() {
  logging.configure()
  logging.set_level(logging.Info)
  process.sleep(500)

  let webdriver =
    driver.new()
    |> driver.goto("https://gleam.run/")
  // |> query.element(by.xpath("/html/body/div/div/h1"))
  // |> input.click()
  // |> query.inner_text(by.xpath("/html/body/div/div/h1"))
  // assert text == "Hello, Joe!"

  process.sleep(500)

  let testdriver = #(webdriver.socket, webdriver.context)
  let testdriver =
    browsing_context.locate_nodes(
      testdriver,
      browsing_context.XPathLocator("/html/body/div[1]/div/div/div[2]/div/a"),
      None,
      None,
    )

  let webdriver = testdriver.0
  let assert Ok(locator) = testdriver.1 |> list.first()
  let assert Some(locator_id) = locator.shared_id

  input.perform_actions(#(webdriver.0, webdriver.1), [
    input.PointerSource(
      input.PointerSourceActions(uuid.nil, None, [
        input.PointerMove(input.PointerMoveAction(
          0,
          0,
          None,
          Some(
            input.Element(
              input.ElementOrigin(script.SharedReference(locator_id, None)),
            ),
          ),
        )),
        input.PointerDown(input.PointerDownAction(0)),
        input.PointerUp(input.PointerUpAction(0)),
      ]),
    ),
  ])

  let _ = browsing_context.get_tree(webdriver.0, None, None)

  process.sleep(1000)
}
