import butterbee/bidi/script/commands/call_function
import butterbee/bidi/script/types/local_value
import butterbee/bidi/script/types/primitive_protocol_value.{
  BigInt, Boolean, Null, Number, String, Undefined,
}
import butterbee/bidi/script/types/remote_reference
import butterbee/bidi/script/types/remote_value.{type RemoteValue}
import butterbee/bidi/script/types/target
import butterbee/commands/script
import butterbee/internal/lib
import butterbee/query
import butterbee/webdriver.{type WebDriver}
import gleam/bool
import gleam/list
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
  driver_with_node: #(WebDriver, List(query.Node)),
) -> #(WebDriver, String) {
  let #(driver, node) = driver_with_node

  let assert Ok(_) = lib.single_element(node)
    as "List of nodes has more than one element, expected exactly one"

  let #(_, inner_text) = inner_texts(driver_with_node)

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
///   driver.new()
///   |> driver.goto("https://gleam.run/")
///   |> query.nodes(by.css("a.logo"))
///   |> nodes.inner_texts()
/// ```
///
pub fn inner_texts(
  driver_with_nodes: #(WebDriver, List(query.Node)),
) -> #(WebDriver, List(String)) {
  let #(driver, nodes) = driver_with_nodes

  let target = target.new_context_target(driver.context)

  let function = "function(node) { return node.innerText; }"

  let inner_texts =
    list.map(nodes, fn(node) {
      let assert Some(shared_id) = node.value.shared_id
        as "Node does not have a shared id"

      let node =
        local_value.remote_reference(remote_reference.remote_reference_from_id(
          shared_id,
        ))

      let params =
        call_function.new(target)
        |> call_function.with_function(function)
        |> call_function.with_arguments([node])

      let assert Ok(call_function_result) =
        script.call_function(driver.socket, params)

      let remote_value = call_function_result.result.result

      parse_inner_text(remote_value)
    })

  #(driver, inner_texts)
}

fn parse_inner_text(remote_value: RemoteValue) -> String {
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

  inner_text
}
