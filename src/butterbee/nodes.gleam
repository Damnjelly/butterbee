import butterbee/bidi/script/commands/call_function
import butterbee/bidi/script/types/local_value
import butterbee/bidi/script/types/primitive_protocol_value.{
  BigInt, Boolean, Null, Number, String, Undefined,
}
import butterbee/bidi/script/types/remote_reference
import butterbee/bidi/script/types/remote_value
import butterbee/bidi/script/types/target
import butterbee/commands/script
import butterbee/driver
import butterbee/query
import gleam/bool
import gleam/option.{None, Some}

///
/// Returns the inner text of the node.
/// 
/// # Example
///
/// This example finds the first node matching the css selector `a.logo` and returns its inner text:
///
/// ```gleam
/// let example =
///   driver.new()
///   |> driver.goto("https://gleam.run/")
///   |> query.node(by.css("a.logo"))
///   |> nodes.inner_text()
/// ```
///
pub fn inner_text(
  driver_with_node: #(driver.WebDriver, query.Node),
) -> #(driver.WebDriver, String) {
  let #(driver, node) = driver_with_node

  let assert Some(shared_id) = node.value.shared_id
    as "Node does not have a shared id"

  let result =
    script.call_function(
      driver.socket,
      call_function.CallFunctionParameters(
        function_declaration: "function(node) { return node.innerText; }",
        await_promise: False,
        target: target.Context(target.ContextTarget(driver.context, None)),
        arguments: Some([
          local_value.RemoteReference(
            remote_reference.Shared(remote_reference.SharedReference(
              shared_id,
              None,
            )),
          ),
        ]),
      ),
    )

  let assert Ok(evaluate_result) = result

  let remote_value = evaluate_result.result.result
  let inner_text = case remote_value {
    remote_value.PrimitiveProtocol(value) -> {
      case value {
        Undefined(_) -> "undefined"
        Null(_) -> "null"
        String(value) -> value.value
        Number(value) -> primitive_protocol_value.number_to_string(value.value)
        Boolean(value) -> bool.to_string(value.value)
        BigInt(value) -> value.value
      }
    }
    _ -> panic as "Expected primitive protocol"
  }

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
///   driver.new()
///   |> driver.goto("https://gleam.run/")
///   |> query.nodes(by.css("a.logo"))
///   |> nodes.inner_texts()
/// ```
///
pub fn inner_texts(
  driver_with_nodes: #(driver.WebDriver, List(query.Node)),
) -> #(driver.WebDriver, List(String)) {
  todo
}
