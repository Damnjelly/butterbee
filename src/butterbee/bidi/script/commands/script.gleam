import butterbee/bidi/browsing_context/types/browsing_context.{
  type BrowsingContext,
}
import butterbee/bidi/script/types/local_value.{type LocalValue}
import butterbee/bidi/script/types/target.{type Target}
import butterbee/internal/socket
import gleam/option.{type Option}

pub type CallFunctionParameters {
  CallFunctionParameters(
    function_declaration: String,
    await_promise: Bool,
    target: Option(Target),
    arguments: Option(List(LocalValue)),
    //TODO: result_ownership: Option(ResultOwnership),
    //TODO: serialization_options: Option(SerializationOptions),
    //TODO: this: Option(LocalValue),
    //TODO: user_activation: Option(Bool),
  )
}

pub fn call_function(
  driver: #(socket.WebDriverSocket, BrowsingContext),
  params: CallFunctionParameters,
) -> a {
  todo
}
