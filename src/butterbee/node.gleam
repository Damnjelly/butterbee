import butterbee/bidi/script/commands/script
import butterbee/bidi/script/types/local_value
import butterbee/bidi/script/types/primitive_protocol_value.{
  BigInt, Boolean, Null, Number, String, Undefined,
}
import butterbee/bidi/script/types/remote_reference
import butterbee/bidi/script/types/remote_value
import butterbee/bidi/script/types/target
import butterbee/driver
import butterbee/query
import gleam/bool
import gleam/option.{None, Some}

pub fn inner_text(
  driver_with_node: #(driver.WebDriver, query.Node),
) -> #(driver.WebDriver, String) {
  let driver = driver_with_node.0
  let node = driver_with_node.1

  let assert Some(shared_id) = node.value.shared_id
    as "Node does not have a shared id"

  let result =
    script.call_function(
      driver.socket,
      script.CallFunctionParameters(
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

  let remote_value = result.result.result
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
