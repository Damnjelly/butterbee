////
//// The action module contains functions to perform actions on DOM nodes
////

import butterbee/commands/input
import butterbee/internal/error
import butterbee/internal/retry
import butterbee/key
import butterbee/node
import butterbee/webdriver.{type WebDriver}
import butterbidi/definition
import butterbidi/input/commands/perform_actions
import butterbidi/script/types/remote_reference
import butterbidi/script/types/remote_value
import gleam/list
import gleam/option.{None}
import gleam/result
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
    case driver.state {
      Error(error) -> Error(error)
      Ok(node_remote_value) -> {
        use shared_id <- result.try({
          node_remote_value.shared_id
          |> option.to_result(error.NodeDoesNotHaveSharedId)
        })

        use context <- result.try({ webdriver.get_context(driver) })

        let params =
          perform_actions.default(context)
          |> perform_actions.with_actions([
            perform_actions.with_pointer_actions(
              "mouse action",
              list.new()
                |> list.append(move_to_element(shared_id))
                |> list.append(
                  click_action(key.mouse_button_to_int(mouse_button)),
                ),
            ),
          ])

        node.do(driver, node.scroll_into_view())
        perform(driver, params)
      }
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

    let _ = webdriver.do(driver, click(key.LeftClick))

    case webdriver.get_context(driver) {
      Error(error) -> Error(error)
      Ok(context) -> {
        let params =
          perform_actions.default(context)
          |> perform_actions.with_actions([
            perform_actions.with_key_actions(
              "entering " <> keys,
              list.new() |> list.append(enter_keys_action(key_list)),
            ),
          ])

        perform(driver, params)
      }
    }
    |> webdriver.map_state(driver)
  }
}

///
/// A helper function that moves the mouse to the given node
///
pub fn move_to_element(
  shared_id: Uuid,
) -> List(perform_actions.PointerSourceAction) {
  [
    perform_actions.pointer_move_action(
      0,
      0,
      None,
      perform_actions.element_origin(remote_reference.shared_reference_from_id(
        shared_id,
      )),
    ),
  ]
}

pub fn click_action(
  mouse_button: Int,
) -> List(perform_actions.PointerSourceAction) {
  [
    perform_actions.pointer_down_action(mouse_button),
    perform_actions.pointer_up_action(mouse_button),
  ]
}

///
/// A helper function to convert a list of keysactions that simulates the user pressing the keys
///
pub fn enter_keys_action(
  keys: List(String),
) -> List(perform_actions.KeySourceAction) {
  list.map(keys, fn(key) {
    [perform_actions.key_down_action(key), perform_actions.key_up_action(key)]
  })
  |> list.flatten()
}

pub fn perform(
  driver: WebDriver(remote_value.NodeRemoteValue),
  params: perform_actions.PerformActionsParameters,
) -> Result(definition.CommandResponse, error.ButterbeeError) {
  case webdriver.get_socket(driver) {
    Error(error) -> Error(error)
    Ok(socket) -> {
      retry.until_ok(fn() { input.perform_actions(socket, params).1 })
    }
  }
}
