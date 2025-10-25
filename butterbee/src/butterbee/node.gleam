////
//// The nodes module contains functions to work with DOM nodes
////

import butterbee/internal/error
import butterbee/internal/function
import butterbee/internal/retry
import butterbee/webdriver.{type WebDriver}
import butterbidi/script/types/local_value
import butterbidi/script/types/remote_value

pub fn get(
  driver: WebDriver(remote_value.NodeRemoteValue),
  action: fn(_) -> WebDriver(new_state),
) -> WebDriver(new_state) {
  webdriver.do(driver, action)
}

pub fn get_all(
  driver: WebDriver(List(remote_value.NodeRemoteValue)),
  action: fn(_) -> WebDriver(new_state),
) -> WebDriver(new_state) {
  webdriver.do(driver, action)
}

pub fn do(
  driver: WebDriver(remote_value.NodeRemoteValue),
  action: fn(_) -> WebDriver(new_state),
) -> WebDriver(remote_value.NodeRemoteValue) {
  webdriver.do(driver, action)
  driver
}

///
/// Get the inner text of the node.
/// 
/// # Example
///
/// This example finds the first node matching the css selector `a.logo`
/// and returns its inner text:
///
/// ```gleam
/// let example =
///   webdriver.new()
///   |> webdriver.goto("https://gleam.run/")
///   |> nodes.query(by.css("a.logo"))
///   |> nodes.inner_text()
/// ```
///
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

/// 
/// Returns the inner texts of the nodes.
/// 
/// # Example
///
/// This example finds all nodes matching the css selector `a.logo` and returns their inner texts:
///
/// ```gleam
/// let example =
///   webdriver.new()
///   |> webdriver.goto("https://gleam.run/")
///   |> nodes.query(by.css("a.logo"))
///   |> nodes.inner_texts()
/// ```
///
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

pub fn scroll_into_view() {
  let function = "function() { this.scrollIntoView(true); }"
  fn(driver: WebDriver(remote_value.NodeRemoteValue)) {
    driver
    |> function.on_node([], function)
    |> webdriver.map_state(driver)
  }
}
