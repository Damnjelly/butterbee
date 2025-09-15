import butterbee/bidi/script/commands/call_function
import butterbee/bidi/script/types/local_value
import butterbee/bidi/script/types/remote_reference
import butterbee/bidi/script/types/remote_value
import butterbee/bidi/script/types/target
import butterbee/commands/script
import butterbee/internal/lib
import butterbee/webdriver.{type WebDriver}
import gleam/list
import gleam/option.{type Option, None, Some}
import youid/uuid.{type Uuid}

pub type Nodes {
  Node(value: remote_value.NodeRemoteValue)
  Nodes(value: List(remote_value.NodeRemoteValue))
}

pub fn new(value: List(remote_value.NodeRemoteValue)) -> Nodes {
  Nodes(value)
}

pub fn unwrap(nodes: Nodes) -> List(remote_value.NodeRemoteValue) {
  case nodes {
    Node(node) -> [node]
    Nodes(nodes) -> nodes
  }
}

pub fn to_shared_ids(nodes: Nodes) -> List(Uuid) {
  let unwrap = fn(ids: Option(Uuid)) -> Uuid {
    let assert Some(ids) = ids as "Node does not have a shared id"
    ids
  }

  case nodes {
    Node(node) -> {
      [unwrap(node.shared_id)]
    }
    Nodes(nodes) -> {
      list.map(nodes, fn(node) { unwrap(node.shared_id) })
    }
  }
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
///   driver.new()
///   |> driver.goto("https://gleam.run/")
///   |> node(by.css("a.logo"))
///   |> nodes.inner_text()
/// ```
///
pub fn inner_text(driver_with_node: #(WebDriver, Nodes)) -> #(WebDriver, String) {
  let #(driver, node) = driver_with_node

  let assert Ok(_) = unwrap(node) |> lib.single_element
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
///   |> nodes(by.css("a.logo"))
///   |> nodes.inner_texts()
/// ```
///
pub fn inner_texts(
  driver_with_nodes: #(WebDriver, Nodes),
) -> #(WebDriver, List(String)) {
  let #(driver, nodes) = driver_with_nodes

  let target = target.new_context_target(driver.context)

  let function = "function(node) { return node.innerText; }"

  let nodes = unwrap(nodes)

  let inner_texts =
    list.map(nodes, fn(node) {
      let assert Some(shared_id) = node.shared_id

      let node =
        shared_id
        |> remote_reference.remote_reference_from_id()
        |> local_value.remote_reference()

      let params =
        call_function.new(target)
        |> call_function.with_function(function)
        |> call_function.with_arguments([node])

      let assert Ok(call_function_result) =
        script.call_function(driver.socket, params)

      let remote_value = call_function_result.result.result

      remote_value.remote_value_to_string(remote_value)
    })

  #(driver, inner_texts)
}
