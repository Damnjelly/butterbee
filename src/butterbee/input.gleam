import butterbee/bidi/definition
import butterbee/bidi/input/commands/perform_actions
import butterbee/bidi/input/types/element_origin
import butterbee/bidi/script/types/remote_reference
import butterbee/commands/input
import butterbee/driver
import butterbee/internal/retry
import butterbee/query
import gleam/list
import gleam/option.{None, Some}
import gleam/string
import logging

pub fn click(
  driver_with_node: #(driver.WebDriver, query.Node),
) -> driver.WebDriver {
  let #(driver, node) = driver_with_node

  let assert Some(shared_id) = node.value.shared_id
    as "Node does not have a shared id"

  let _ =
    retry.until_ok(
      fn() {
        input.perform_actions(
          driver.socket,
          perform_actions.PerformActionsParameters(driver.context, [
            perform_actions.PointerSource(
              perform_actions.PointerSourceActions("mouse", None, [
                perform_actions.PointerMove(perform_actions.PointerMoveAction(
                  0,
                  0,
                  option.None,
                  option.Some(
                    perform_actions.Element(
                      element_origin.ElementOrigin(
                        remote_reference.SharedReference(shared_id, option.None),
                      ),
                    ),
                  ),
                )),
                perform_actions.PointerDown(perform_actions.PointerDownAction(0)),
                perform_actions.PointerUp(perform_actions.PointerUpAction(0)),
              ]),
            ),
          ]),
        )
      },
      fn(result) {
        case result.1 {
          Ok(a) -> Ok(a)
          Error(b) -> {
            logging.log(
              logging.Debug,
              "Click failed, error: " <> string.inspect(b) <> " retrying",
            )
            Error(b)
          }
        }
      },
    )

  driver
}

pub fn enter_keys(
  driver_with_node: #(driver.WebDriver, query.Node),
  keys: String,
) -> driver.WebDriver {
  let #(driver, node) = driver_with_node

  let assert Some(shared_id) = node.value.shared_id
    as "Node does not have a shared id"

  let key_list = string.split(keys, "")

  let _ = click(driver_with_node)

  input.perform_actions(
    driver.socket,
    perform_actions.PerformActionsParameters(driver.context, [
      perform_actions.KeySource(perform_actions.KeySourceActions(
        "entering " <> keys,
        list.map(key_list, fn(key) {
          [
            perform_actions.KeyDown(perform_actions.KeyDownAction(key)),
            perform_actions.KeyUp(perform_actions.KeyUpAction(key)),
          ]
        })
          |> list.flatten(),
      )),
    ]),
  )

  driver
}
