//// The node module contains functions to work with DOM nodes
//// 
//// ## Usage
////
//// In your tests, call 
//// [`get`](https://hexdocs.pm/butterbee/butterbee/node.html#get),
//// [`do`](https://hexdocs.pm/butterbee/butterbee/node.html#do), 
//// [`get_all`](https://hexdocs.pm/butterbee/butterbee/node.html#get_all), or 
//// [`do_all`](https://hexdocs.pm/butterbee/butterbee/node.html#do_all) 
//// to perform an action on a node. These function expect a parameter `action` 
//// that is the action to perform. possible actions are listed in this module and in the 
//// [action](https://hexdocs.pm/butterbee/butterbee/action.html) module.
////
//// ### Example
////
//// ```gleam
//// let text =
////   driver
////   |> driver.goto("https://gleam.run/")
////   |> get.node(by.css("a.logo"))
////   // perform an action on the node, without updating the state
////   |> node.do(action.click(key.LeftClick))
////   // get the text of the node, the state is updated with the result of the action
////   |> node.get(node.text()) 
//// ```
////
//// Performing actions on nodes directly is useful for one-off situations, 
//// but if you want to make your tests more reusable, its recommended to use 
//// [page modules](https://hexdocs.pm/butterbee/page-modules.html).

import butterbee/internal/error
import butterbee/internal/function
import butterbee/internal/retry
import butterbee/webdriver.{type WebDriver}
import butterbidi/script/types/local_value
import butterbidi/script/types/remote_value

/// Perform an action on a node, updating the state with the result of the action
pub fn get(
  driver: WebDriver(remote_value.NodeRemoteValue),
  action: fn(_) -> WebDriver(new_state),
) -> WebDriver(new_state) {
  webdriver.do(driver, action)
}

/// Perform an action on a list of nodes, updating the state with the result of the action
pub fn get_all(
  driver: WebDriver(List(remote_value.NodeRemoteValue)),
  action: fn(_) -> WebDriver(new_state),
) -> WebDriver(new_state) {
  webdriver.do(driver, action)
}

/// Perform an action on a node, without updating the state of the driver
pub fn do(
  driver: WebDriver(remote_value.NodeRemoteValue),
  action: fn(_) -> WebDriver(new_state),
) -> WebDriver(remote_value.NodeRemoteValue) {
  webdriver.do(driver, action)
  driver
}

/// Perform an action on a list of nodes, without updating the state of the driver
pub fn do_all(
  driver: WebDriver(List(remote_value.NodeRemoteValue)),
  action: fn(_) -> WebDriver(new_state),
) -> WebDriver(List(remote_value.NodeRemoteValue)) {
  webdriver.do(driver, action)
  driver
}

/// Get text from a node, tries different methods to get the text from a node. 
/// First tries `textContent`, then `innerText`, then `value`.
/// Returns null if no text is found.
pub fn text() -> fn(WebDriver(remote_value.NodeRemoteValue)) ->
  WebDriver(String) {
  let function =
    "function() { return this.textContent || this.innerText || this.value || null; }"
  fn(driver: WebDriver(remote_value.NodeRemoteValue)) -> WebDriver(String) {
    driver
    |> webdriver.with_state({
      retry.until_ok(fn() {
        let result =
          driver
          |> function.on_node([], function)
          |> function.result_to_string

        case result {
          Error(error) -> Error(error)
          Ok("null") -> Error(error.NodeTextIsNull)
          Ok(text) -> Ok(text)
        }
      })
    })
  }
}

/// Get text from a list of nodes, tries different methods to get the text from a node. 
/// First tries `textContent`, then `innerText`, then `value`.
/// Returns null if no text is found.
pub fn texts() -> fn(WebDriver(List(remote_value.NodeRemoteValue))) ->
  WebDriver(List(String)) {
  let function =
    "function() { 
      return Array.from(this, n => n.innerText || n.textContent || n.value || null); 
    }"
  fn(driver: WebDriver(List(remote_value.NodeRemoteValue))) {
    driver
    |> function.on_nodes([], function)
    |> function.result_to_string_list
    |> webdriver.map_state(driver)
  }
}

/// Get the inner text of a node, returns an empty string if no text is found.
pub fn inner_text() -> fn(WebDriver(remote_value.NodeRemoteValue)) ->
  WebDriver(String) {
  let function = "function() { return this.innerText; }"
  fn(driver: WebDriver(remote_value.NodeRemoteValue)) {
    driver
    |> function.on_node([], function)
    |> function.result_to_string
    |> webdriver.map_state(driver)
  }
}

/// Get the inner text of a list of nodes, returns an empty string if no text is found.
pub fn inner_texts() -> fn(WebDriver(List(remote_value.NodeRemoteValue))) ->
  WebDriver(List(String)) {
  let function = "function() { return Array.from(this, n => n.innerText); }"
  fn(driver: WebDriver(List(remote_value.NodeRemoteValue))) {
    driver
    |> function.on_nodes([], function)
    |> function.result_to_string_list
    |> webdriver.map_state(driver)
  }
}

/// Set the value of a node. Useful for setting text fields.
pub fn set_value(
  value: String,
) -> fn(WebDriver(remote_value.NodeRemoteValue)) -> WebDriver(String) {
  let function = "function(value) { this.value = value; }"
  fn(driver: WebDriver(remote_value.NodeRemoteValue)) {
    driver
    |> function.on_node([local_value.string(value)], function)
    |> function.result_to_string
    |> webdriver.map_state(driver)
  }
}

/// Get the value of a node.
pub fn value() -> fn(WebDriver(remote_value.NodeRemoteValue)) ->
  WebDriver(String) {
  let function = "function() { return this.value; }"
  fn(driver: WebDriver(remote_value.NodeRemoteValue)) {
    driver
    |> function.on_node([], function)
    |> function.result_to_string
    |> webdriver.map_state(driver)
  }
}

/// Get the value of a list of nodes.
pub fn values() -> fn(WebDriver(List(remote_value.NodeRemoteValue))) ->
  WebDriver(List(String)) {
  let function = "function() { return Array.from(this, n => n.value); }"
  fn(driver: WebDriver(List(remote_value.NodeRemoteValue))) {
    driver
    |> function.on_nodes([], function)
    |> function.result_to_string_list
    |> webdriver.map_state(driver)
  }
}

/// Set an attribute of a node.
pub fn set_attribute(
  attribute: String,
  value: String,
) -> fn(WebDriver(remote_value.NodeRemoteValue)) -> WebDriver(String) {
  let function =
    "function(attribute, value) { this.setAttribute(attribute, value); }"
  fn(driver: WebDriver(remote_value.NodeRemoteValue)) {
    driver
    |> function.on_node(
      [local_value.string(attribute), local_value.string(value)],
      function,
    )
    |> function.result_to_string
    |> webdriver.map_state(driver)
  }
}

/// Check if a node has an attribute.
pub fn has_attribute(
  attribute: String,
) -> fn(WebDriver(remote_value.NodeRemoteValue)) -> WebDriver(Bool) {
  let function = "function(attribute) { return this.hasAttribute(attribute); }"
  fn(driver: WebDriver(remote_value.NodeRemoteValue)) {
    driver
    |> function.on_node([local_value.string(attribute)], function)
    |> function.result_to_bool
    |> webdriver.map_state(driver)
  }
}

/// Scroll a node into view.
pub fn scroll_into_view() {
  let function = "function() { this.scrollIntoView(true); }"
  fn(driver: WebDriver(remote_value.NodeRemoteValue)) {
    driver
    |> function.on_node([], function)
    |> webdriver.map_state(driver)
  }
}

/// Gets the `inner text` of the selected option of a `select` element.
pub fn selected_text() -> fn(WebDriver(remote_value.NodeRemoteValue)) ->
  WebDriver(String) {
  fn(driver: WebDriver(remote_value.NodeRemoteValue)) -> WebDriver(String) {
    driver
    |> function.on_node(
      [],
      "function() { return this.options[this.selectedIndex].text; }",
    )
    |> function.result_to_string
    |> webdriver.map_state(driver)
  }
}

/// Selects the value of a `select` element based on the `inner text` of one of its options.
pub fn select_option(
  option: String,
) -> fn(WebDriver(remote_value.NodeRemoteValue)) ->
  WebDriver(remote_value.NodeRemoteValue) {
  // Sets the value of a <select> element based on the innerText of one of its options.
  // @param {string} innerTextValue – The exact innerText of the option that should become selected.
  // @this {HTMLSelectElement} – The select element whose value will be updated.
  let function =
    "function setSelectByInnerText(innerTextValue) {
      if (!this || this.tagName !== 'SELECT') {
        throw new TypeError('Function must be called on a <select> element');
      }

      for (let i = 0; i < this.options.length; i++) {
        if (this.options[i].innerText === innerTextValue) {
          this.selectedIndex = i;
          return; // Stop once the match is found
        }
      }

      throw new Error(`No option with innerText \"${innerTextValue}\" found`);
    }"

  fn(driver: WebDriver(remote_value.NodeRemoteValue)) {
    let _ =
      driver
      |> webdriver.with_state({
        case driver.state {
          Error(error) -> Error(error)
          Ok(node) -> Ok(local_value.node(node))
        }
      })
      |> function.on_value([local_value.string(option)], function)
    driver
  }
}
