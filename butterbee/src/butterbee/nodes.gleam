////
//// The nodes module contains functions to work with DOM nodes
////

import butterbee/commands/script
import butterbee/webdriver.{type WebDriver}
import butterbidi/definition
import butterbidi/script/commands/call_function
import butterbidi/script/types/evaluate_result.{type EvaluateResult}
import butterbidi/script/types/local_value
import butterbidi/script/types/remote_reference
import butterbidi/script/types/remote_value
import butterbidi/script/types/target
import butterlib/log
import gleam/list
import gleam/option.{Some}
import gleam/result
import gleam/string
import youid/uuid.{type Uuid}

pub type Nodes {
  Nodes(value: List(remote_value.NodeRemoteValue))
}

pub fn new(value: List(remote_value.NodeRemoteValue)) -> Nodes {
  Nodes(value)
}

///
/// Returns a Nodes struct containing only the first node matching the given locator.
/// Returns an error if no nodes are found.
/// 
pub fn first(nodes: Nodes) -> Result(Nodes, Nil) {
  list.first(nodes.value)
  |> result.map(fn(node) { Nodes([node]) })
}

///
/// Extracts the shared ids from nodes. Can panic if a node does not have a shared id.
///
pub fn to_shared_ids(nodes: Nodes) -> List(Uuid) {
  list.map(nodes.value, fn(node) {
    let assert Some(ids) = node.shared_id as "Node does not have a shared id"
    ids
  })
}

///
/// Returns the inner text of the node.
/// 
/// # Example
///
/// This example finds the first node matching the css selector `a.logo` and returns its inner text:
///
/// ```gleam
/// let example =
///   webdriver.new()
///   |> webdriver.goto("https://gleam.run/")
///   |> nodes.query(by.css("a.logo"))
///   |> nodes.inner_text()
/// ```
///
pub fn inner_text(driver_with_node: #(WebDriver, Nodes)) -> #(WebDriver, String) {
  let #(_driver, node) = driver_with_node

  let assert Ok(_) = first(node)
    as "List of nodes has more than one element, expected exactly one"

  let #(driver, inner_text) = inner_texts(driver_with_node)

  let assert Ok(inner_text) = list.first(inner_text) as "No inner text found"

  #(driver, inner_text)
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
pub fn inner_texts(
  driver_with_nodes: #(WebDriver, Nodes),
) -> #(WebDriver, List(String)) {
  let #(driver, _nodes) = driver_with_nodes

  let function = "function(node) { return node.innerText; }"

  let #(_, results) = call_function(driver_with_nodes, function)

  let inner_texts =
    list.map(results, fn(result) {
      let call_function_result = case result {
        Ok(call_function_result) -> call_function_result
        Error(error) ->
          log.error_and_continue(
            "Error calling function: " <> string.inspect(error),
            evaluate_result.evaulate_result_failure,
          )
      }

      let remote_value = case call_function_result {
        evaluate_result.SuccessResult(success) -> success.result
        evaluate_result.ExceptionResult(exception) ->
          log.error_and_continue(
            "Error calling function: " <> string.inspect(exception),
            exception.exception_details.exception,
          )
      }

      remote_value.remote_value_to_string(remote_value)
    })

  #(driver, inner_texts)
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
  driver_with_nodes: #(WebDriver, Nodes),
  function: String,
) -> #(WebDriver, List(Result(EvaluateResult, definition.ErrorResponse))) {
  let #(driver, nodes) = driver_with_nodes

  let target = target.new_context_target(driver.context)

  let results =
    list.map(nodes.value, fn(node) {
      let assert Some(shared_id) = node.shared_id

      let node =
        shared_id
        |> remote_reference.remote_reference_from_id()
        |> local_value.remote_reference()

      let params =
        call_function.new(target)
        |> call_function.with_function(function)
        |> call_function.with_arguments([node])

      script.call_function(driver.socket, params)
    })

  #(driver, results)
}
