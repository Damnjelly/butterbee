import butterbee/driver
import butterbee/internal/bidi/input
import butterbee/internal/bidi/script
import butterbee/query
import gleam/option.{None, Some}
import youid/uuid

pub fn click(
  driver_with_node: #(driver.WebDriver, query.Node),
) -> driver.WebDriver {
  let driver = driver_with_node.0
  let node = driver_with_node.1

  let assert Some(shared_id) = node.value.shared_id
    as "Node does not have a shared id"

  let #(socket, context) =
    input.perform_actions(#(driver.socket, driver.context), [
      input.PointerSource(
        input.PointerSourceActions(uuid.nil, None, [
          input.PointerMove(input.PointerMoveAction(
            0,
            0,
            option.None,
            option.Some(
              input.Element(
                input.ElementOrigin(script.SharedReference(
                  shared_id,
                  option.None,
                )),
              ),
            ),
          )),
          input.PointerDown(input.PointerDownAction(0)),
          input.PointerUp(input.PointerUpAction(0)),
        ]),
      ),
    ])

  driver.WebDriver(socket, context)
}
