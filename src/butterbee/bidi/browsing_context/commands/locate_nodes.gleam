import butterbee/bidi/browsing_context/types/browsing_context.{
  type BrowsingContext,
}
import butterbee/bidi/browsing_context/types/locator.{type Locator}
import butterbee/bidi/script/types/remote_reference
import butterbee/bidi/script/types/remote_value
import butterbee/bidi/script/types/serialization_options.{
  type SerializationOptions,
}
import gleam/dynamic/decode
import gleam/json.{type Json}
import gleam/option.{type Option, None, Some}
import youid/uuid

pub type LocateNodesParameters {
  LocateNodesParameters(
    context: BrowsingContext,
    locator: Locator,
    max_node_count: Option(Int),
    serialization_options: Option(SerializationOptions),
    start_nodes: Option(List(remote_reference.SharedReference)),
  )
}

pub fn locate_nodes_parameters_to_json(
  locate_nodes_parameters: LocateNodesParameters,
) -> Json {
  let LocateNodesParameters(
    context:,
    locator:,
    max_node_count:,
    serialization_options:,
    start_nodes:,
  ) = locate_nodes_parameters
  json.object([
    #("context", json.string(uuid.to_string(context.id))),
    #("locator", locator.locator_to_json(locator)),
    #("max_node_count", case max_node_count {
      None -> json.null()
      Some(value) -> json.int(value)
    }),
    #("serialization_options", case serialization_options {
      None -> json.null()
      Some(value) -> serialization_options.serialization_options_to_json(value)
    }),
    #("start_nodes", case start_nodes {
      None -> json.null()
      Some(value) ->
        json.array(value, remote_reference.shared_reference_to_json)
    }),
  ])
}

pub type LocateNodesResult {
  LocateNodesResult(nodes: List(remote_value.NodeRemoteValue))
}

pub fn locate_nodes_result_decoder() -> decode.Decoder(LocateNodesResult) {
  use nodes <- decode.field(
    "nodes",
    decode.list(remote_value.node_remote_value_decoder()),
  )
  decode.success(LocateNodesResult(nodes:))
}
