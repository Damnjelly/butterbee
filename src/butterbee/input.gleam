import butterbee/bidi/input/commands/perform_actions
import butterbee/bidi/script/types/remote_reference
import butterbee/commands/input
import butterbee/driver
import butterbee/internal/lib
import butterbee/internal/retry
import butterbee/query
import gleam/list
import gleam/option.{None, Some}
import gleam/string
import logging
import youid/uuid.{type Uuid}

pub const left_click = 0

///
/// Perfoms a click on the given node
/// Will panic if the node list has more than one element
/// 
/// # Example
///
/// This example perfoms a click on the node with the css selector `a.logo`:
///
/// ```gleam
/// let example = driver.new()
///   |> driver.goto("https://gleam.run/")
///   |> query.node(by.css("a.logo"))
///   |> input.click()
/// ```
///
pub fn click(
  driver_with_node: #(driver.WebDriver, List(query.Node)),
) -> driver.WebDriver {
  let #(driver, node) = driver_with_node

  let assert Ok(node) = lib.single_element(node)
    as "List of nodes has more than one element, expected exactly one"

  let assert Some(shared_id) = node.value.shared_id
    as "Node does not have a shared id"

  let params =
    perform_actions.default(driver.context)
    |> perform_actions.with_actions([
      {
        perform_actions.pointer_actions("mouse", [
          move_to_element(shared_id),
          perform_actions.pointer_down_action(left_click),
          perform_actions.pointer_up_action(left_click),
        ])
      },
    ])

  let _ =
    retry.until_ok(
      fn() { input.perform_actions(driver.socket, params) },
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

///
/// Enters the given keys into the browser
/// This function expects a list of nodes, but will panic if the list has more than one element
/// 
/// # Example
///
/// This example enters the text "gleam" into the node with the css selector `a.logo`:
///
/// ```gleam
/// let example = driver.new()
///   |> driver.goto("https://gleam.run/")
///   |> query.node(by.css("a.logo"))
///   |> input.enter_keys("gleam")
/// ```
///
pub fn enter_keys(
  driver_with_node: #(driver.WebDriver, List(query.Node)),
  keys: String,
) -> driver.WebDriver {
  let #(driver, node_list) = driver_with_node

  let assert Ok(node) = lib.single_element(node_list)
    as "List of nodes has more than one element, expected exactly one"

  let assert Some(_shared_id) = node.value.shared_id
    as "Node does not have a shared id"

  let key_list = string.split(keys, "")

  let _ = click(#(driver, node_list))

  let params =
    perform_actions.default(driver.context)
    |> perform_actions.with_actions([
      perform_actions.key_actions(
        "entering " <> keys,
        enter_keys_action(key_list),
      ),
    ])

  input.perform_actions(driver.socket, params)

  driver
}

fn move_to_element(shared_id: Uuid) -> perform_actions.PointerSourceAction {
  perform_actions.pointer_move_action(
    0,
    0,
    None,
    perform_actions.element_origin(remote_reference.shared_reference_from_id(
      shared_id,
    )),
  )
}

fn enter_keys_action(
  keys: List(String),
) -> List(perform_actions.KeySourceAction) {
  list.map(keys, fn(key) {
    [perform_actions.key_down_action(key), perform_actions.key_up_action(key)]
  })
  |> list.flatten()
}
