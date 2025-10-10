////
//// The input module contains high level functions to perform user input actions in the browser
////

import butterbee/commands/input
import butterbee/internal/retry
import butterbee/nodes.{type Nodes}
import butterbee/webdriver.{type WebDriver}
import butterbidi/input/commands/perform_actions
import butterbidi/script/types/remote_reference
import butterlib/log
import gleam/list
import gleam/option.{None}
import gleam/string
import youid/uuid.{type Uuid}

pub type MouseButton {
  LeftClick
  RightClick
}

fn mouse_button_to_int(click: MouseButton) -> Int {
  case click {
    LeftClick -> 0
    RightClick -> 1
  }
}

///
/// Perfoms a click on the given node
/// Will panic if the node list has more than one element
/// 
/// # Example
///
/// This example perfoms a click on the node with the css selector `a.logo`:
///
/// ```gleam
/// let example = webdriver.new()
///   |> webdriver.goto("https://gleam.run/")
///   |> query.node(by.css("a.logo"))
///   |> input.click(input.LeftClick)
/// ```
///
pub fn click(
  driver_with_node: #(WebDriver, Nodes),
  mouse_button: MouseButton,
) -> WebDriver {
  let #(driver, node) = driver_with_node

  let assert Ok(node) = nodes.first(node)
    as "List of nodes has more than one element, expected exactly one"

  let assert Ok(shared_id) =
    nodes.to_shared_ids(node)
    |> list.first()
    as "Node does not have a shared id"

  let params =
    perform_actions.default(driver.context)
    |> perform_actions.with_actions([
      {
        perform_actions.pointer_actions("mouse", [
          move_to_element(shared_id),
          perform_actions.pointer_down_action(mouse_button_to_int(mouse_button)),
          perform_actions.pointer_up_action(mouse_button_to_int(mouse_button)),
        ])
      },
    ])

  let _ =
    retry.until_ok(
      fn() { input.perform_actions(driver.socket, params) },
      fn(result) {
        case result.1 {
          Ok(a) -> Ok(a)
          Error(b) ->
            log.debug_and_continue(
              "Click failed, error: " <> string.inspect(b) <> " retrying",
              Error(b),
            )
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
/// let example = webdriver.new()
///   |> webdriver.goto("https://gleam.run/")
///   |> query.node(by.css("a.logo"))
///   |> input.enter_keys("gleam")
/// ```
///
pub fn enter_keys(
  driver_with_node: #(WebDriver, Nodes),
  keys: String,
) -> WebDriver {
  let #(driver, nodes) = driver_with_node

  let assert Ok(node) = nodes.first(nodes)
    as "List of nodes has more than one element, expected exactly one"

  let assert Ok(_) =
    nodes.to_shared_ids(node)
    |> list.first()
    as "Node does not have a shared id"

  let key_list = string.split(keys, "")

  let _ = click(driver_with_node, LeftClick)

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

///
/// A helper function to convert a list of keysactions that simulates the user pressing the keys
///
fn enter_keys_action(
  keys: List(String),
) -> List(perform_actions.KeySourceAction) {
  list.map(keys, fn(key) {
    [perform_actions.key_down_action(key), perform_actions.key_up_action(key)]
  })
  |> list.flatten()
}
