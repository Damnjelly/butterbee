////
//// The nodes module contains functions to work with DOM nodes
////

import butterbee/commands/script
import butterbee/internal/error
import butterbee/internal/retry
import butterbee/webdriver.{type WebDriver}
import butterbidi/script/commands/call_function
import butterbidi/script/types/evaluate_result.{type EvaluateResult}
import butterbidi/script/types/local_value
import butterbidi/script/types/remote_reference
import butterbidi/script/types/remote_value
import butterbidi/script/types/target
import butterlib/log
import gleam/list
import gleam/option
import gleam/result
import gleam/string

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

const any_text_function: String = "
    function(node) { 
      return node.innerText || node.textContent || node.value || null;
    }
  "

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
  fn(driver: WebDriver(remote_value.NodeRemoteValue)) -> WebDriver(String) {
    call_function(driver, any_text_function)
    |> parse_result()
    |> webdriver.map_state(driver)
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
// TODO: Implement ArrayRemoteValue and create a function that  
// takes a list of nodes and returns a list of inner texts
pub fn texts() -> fn(WebDriver(List(remote_value.NodeRemoteValue))) ->
  WebDriver(List(String)) {
  fn(driver: WebDriver(List(remote_value.NodeRemoteValue))) {
    result.map(driver.state, fn(nodes) {
      list.map(nodes, fn(node) {
        webdriver.map_state(Ok(node), driver)
        |> call_function(any_text_function)
        |> result.map(fn(evaluate_result) {
          case evaluate_result {
            evaluate_result.SuccessResult(success) ->
              remote_value.remote_value_to_string(success.result)
            evaluate_result.ExceptionResult(exception) ->
              log.error_and_continue(
                "Error calling function: " <> string.inspect(exception),
                remote_value.remote_value_to_string(
                  exception.exception_details.exception,
                ),
              )
          }
        })
      })
      |> list.map(fn(result_list) {
        case result_list {
          Ok(result) -> result
          Error(error) ->
            log.error_and_continue(
              "Could not get inner text from node, error: "
                <> string.inspect(error)
                <> ". Returning empty string",
              "",
            )
        }
      })
    })
    |> webdriver.map_state(driver)
  }
}

const inner_text_function: String = "
    function(node) { 
      return node.innerText;
    }
  "

pub fn inner_text() -> fn(WebDriver(remote_value.NodeRemoteValue)) ->
  WebDriver(String) {
  fn(driver: WebDriver(remote_value.NodeRemoteValue)) {
    call_function(driver, inner_text_function)
    |> parse_result()
    |> webdriver.map_state(driver)
  }
}

pub fn inner_texts() -> fn(WebDriver(List(remote_value.NodeRemoteValue))) ->
  WebDriver(List(String)) {
  fn(driver: WebDriver(List(remote_value.NodeRemoteValue))) {
    result.map(driver.state, fn(nodes) {
      list.map(nodes, fn(node) {
        webdriver.map_state(Ok(node), driver)
        |> call_function(inner_text_function)
        |> result.map(fn(evaluate_result) {
          case evaluate_result {
            evaluate_result.SuccessResult(success) ->
              remote_value.remote_value_to_string(success.result)
            evaluate_result.ExceptionResult(exception) ->
              log.error_and_continue(
                "Error calling function: " <> string.inspect(exception),
                remote_value.remote_value_to_string(
                  exception.exception_details.exception,
                ),
              )
          }
        })
      })
      |> list.map(fn(result_list) {
        case result_list {
          Ok(result) -> result
          Error(error) ->
            log.error_and_continue(
              "Could not get inner text from node, error: "
                <> string.inspect(error)
                <> ". Returning empty string",
              "",
            )
        }
      })
    })
    |> webdriver.map_state(driver)
  }
}

const value_function: String = "
    function(node) { 
      return node.value;
    }
  "

pub fn value() -> fn(WebDriver(remote_value.NodeRemoteValue)) ->
  WebDriver(String) {
  fn(driver: WebDriver(remote_value.NodeRemoteValue)) {
    call_function(driver, value_function)
    |> parse_result()
    |> webdriver.map_state(driver)
  }
}

pub fn values() {
  fn(driver: WebDriver(List(remote_value.NodeRemoteValue))) {
    result.map(driver.state, fn(nodes) {
      list.map(nodes, fn(node) {
        webdriver.map_state(Ok(node), driver)
        |> call_function(value_function)
        |> result.map(fn(evaluate_result) {
          case evaluate_result {
            evaluate_result.SuccessResult(success) ->
              remote_value.remote_value_to_string(success.result)
            evaluate_result.ExceptionResult(exception) ->
              log.error_and_continue(
                "Error calling function: " <> string.inspect(exception),
                remote_value.remote_value_to_string(
                  exception.exception_details.exception,
                ),
              )
          }
        })
      })
      |> list.map(fn(result_list) {
        case result_list {
          Ok(result) -> result
          Error(error) ->
            log.error_and_continue(
              "Could not get inner text from node, error: "
                <> string.inspect(error)
                <> ". Returning empty string",
              "",
            )
        }
      })
    })
    |> webdriver.map_state(driver)
  }
}

///
/// Calls a javascript function on nodes.
/// This function is called for every node in the list of nodes.
///
/// The function has 1 parameter, the node to call the function on.
///
/// # Function Example
///
/// ```js
/// function(node) { return node.innerText; }
/// ```
/// 
pub fn call_function(
  driver: WebDriver(remote_value.NodeRemoteValue),
  function: String,
) -> Result(EvaluateResult, error.ButterbeeError) {
  case webdriver.get_context(driver) {
    Error(error) -> Error(error)
    Ok(context) -> {
      use state <- result.try({ driver.state })

      use shared_id <- result.try({
        state.shared_id
        |> option.to_result(error.NodeDoesNotHaveSharedId)
      })
      let target = target.new_context_target(context)

      let node =
        shared_id
        |> remote_reference.remote_reference_from_id()
        |> local_value.remote_reference()

      let params =
        call_function.new(target)
        |> call_function.with_function(function)
        |> call_function.with_arguments([node])

      retry.until_ok(fn() { script.call_function(driver, params) })
    }
  }
}

pub fn parse_result(result: Result(EvaluateResult, error.ButterbeeError)) {
  case result {
    Error(error) -> Error(error)
    Ok(evaluate_result) ->
      case evaluate_result {
        evaluate_result.SuccessResult(success) ->
          Ok(remote_value.remote_value_to_string(success.result))
        evaluate_result.ExceptionResult(exception) -> {
          Ok(remote_value.remote_value_to_string(
            exception.exception_details.exception,
          ))
        }
      }
  }
}
