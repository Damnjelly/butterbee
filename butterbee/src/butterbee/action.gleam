//// The action module contains functions to perform actions on nodes.
////
//// Perform actions by passing the functions in this module to either the 
//// [`node.do`](https://hexdocs.pm/butterbee/node.html#do/2) or 
//// [`node.get`](https://hexdocs.pm/butterbee/node.html#get/2) functions.
////
//// ### Example
////
//// This example performs a click on the node with the css selector `a.logo`:
////
//// ```gleam
//// let example = driver.new(browser.Firefox)
////   |> driver.goto("https://gleam.run/")
////   |> get.node(by.css("a.logo"))
////   |> node.do(action.click(key.LeftClick))
//// ```

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

/// Performs a click on the given node
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

        // Scroll node into view before clicking to avoid
        // Getting the 'out of bounds of viewport dimensions' error
        node.do(driver, node.scroll_into_view())
        perform(driver, params)
      }
    }
    |> webdriver.map_state(driver)
  }
}

/// Simulates a user entering the given keys into the browser.
///
/// NOTE: It is not recommended to use this function for entering text into text fields. 
/// Use the [`node.set_value(value)`](https://hexdocs.pm/butterbee/node.html#do) function instead.
pub fn enter_keys(
  keys: String,
) -> fn(WebDriver(remote_value.NodeRemoteValue)) ->
  WebDriver(definition.CommandResponse) {
  fn(driver: WebDriver(remote_value.NodeRemoteValue)) {
    let _ = webdriver.do(driver, click(key.LeftClick))

    case webdriver.get_context(driver) {
      Error(error) -> Error(error)
      Ok(context) -> {
        let params =
          perform_actions.default(context)
          |> perform_actions.with_actions([
            perform_actions.with_key_actions(
              "entering " <> keys,
              list.new() |> list.append(enter_keys_action(keys)),
            ),
          ])

        perform(driver, params)
      }
    }
    |> webdriver.map_state(driver)
  }
}

/// A helper function that moves the mouse to the given node.
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

/// A helper function that simulates a full click action.
/// Shorthand for pressing a mouse button, then releasing it.
pub fn click_action(
  mouse_button: Int,
) -> List(perform_actions.PointerSourceAction) {
  [
    perform_actions.pointer_down_action(mouse_button),
    perform_actions.pointer_up_action(mouse_button),
  ]
}

/// A helper function to convert a list of keysactions that simulates the user pressing the keys.
/// Shorthand for clicking in a key, letting it go, and pressing the next key.
pub fn enter_keys_action(keys: String) -> List(perform_actions.KeySourceAction) {
  let keys = string.split(keys, "")
  list.map(keys, fn(key) {
    [perform_actions.key_down_action(key), perform_actions.key_up_action(key)]
  })
  |> list.flatten()
}

/// Perform a custom action on a node, useful for creating more complex input actions. 
///
/// ### Example params
///
/// ```gleam
/// let params =
///   perform_actions.default(context)
///   |> perform_actions.with_actions([
///     // with_actions expects a list of actions
///     // actions can be pointer actions, wheel actions, key actions, and a pause action.
///     // These actions are performed in the order they are listed.
///     perform_actions.with_key_actions(
///       "entering " <> keys,
///       list.new() |> list.append(enter_keys_action(key_list)),
///     ),
///   ])
/// ```
///
/// ### Example usage
///
/// The example below performs a custom action on a node
///
/// ```gleam
/// let example = driver.new()
///   |> driver.goto("https://packages.gleam.run/")
///   |> query.node(by.css("input[aria-label='Package name, to search']"))
///   |> node.do(action.perform(params))
/// ```
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
