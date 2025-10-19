////
//// The action module contains functions to perform actions on DOM nodes
////

import butterbee/commands/input
import butterbee/internal/retry
import butterbee/key
import butterbee/node
import butterbee/webdriver.{type WebDriver}
import butterbidi/definition
import butterbidi/input/commands/perform_actions
import butterbidi/script/types/remote_reference
import butterbidi/script/types/remote_value
import butterlib/log
import gleam/list
import gleam/option.{None, Some}
import gleam/string
import youid/uuid.{type Uuid}

///
/// Performs a click on the given node
/// Will panic if the node list has more than one element
/// 
/// # Example
///
/// This example performs a click on the node with the css selector `a.logo`:
///
/// ```gleam
/// let example = webdriver.new()
///   |> webdriver.goto("https://gleam.run/")
///   |> query.node(by.css("a.logo"))
///   |> input.click(input.LeftClick)
/// ```
///
pub fn click(
  mouse_button: key.MouseButton,
) -> fn(WebDriver(remote_value.NodeRemoteValue)) ->
  WebDriver(definition.CommandResponse) {
  fn(driver: WebDriver(remote_value.NodeRemoteValue)) {
    let assert Some(shared_id) = webdriver.assert_state(driver).shared_id
      as "Node does not have a shared id"

    let params =
      perform_actions.default(webdriver.get_context(driver))
      |> perform_actions.with_actions([
        {
          perform_actions.pointer_actions("mouse", [
            move_to_element(shared_id),
            perform_actions.pointer_down_action(key.mouse_button_to_int(
              mouse_button,
            )),
            perform_actions.pointer_up_action(key.mouse_button_to_int(
              mouse_button,
            )),
          ])
        },
      ])

    case
      retry.until_ok(fn() {
        input.perform_actions(webdriver.get_socket(driver), params).1
      })
    {
      Ok(a) -> Ok(a)
      Error(b) ->
        log.debug_and_continue(
          "Click failed, error: " <> string.inspect(b) <> " retrying",
          Error(b),
        )
    }
    |> webdriver.map_state(driver)
  }
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
  keys: String,
) -> fn(WebDriver(remote_value.NodeRemoteValue)) ->
  WebDriver(definition.CommandResponse) {
  fn(driver: WebDriver(remote_value.NodeRemoteValue)) {
    let key_list = string.split(keys, "")

    let _ = node.do(driver, click(key.LeftClick))

    let params =
      perform_actions.default(webdriver.get_context(driver))
      |> perform_actions.with_actions([
        perform_actions.key_actions(
          "entering " <> keys,
          enter_keys_action(key_list),
        ),
      ])

    case
      retry.until_ok(fn() {
        input.perform_actions(webdriver.get_socket(driver), params).1
      })
    {
      Ok(a) -> Ok(a)
      Error(b) ->
        log.debug_and_continue(
          "Click failed, error: " <> string.inspect(b) <> " retrying",
          Error(b),
        )
    }
    |> webdriver.map_state(driver)
  }
}

///
/// A helper function that moves the mouse to the given node
///
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
