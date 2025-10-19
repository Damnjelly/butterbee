import butterbidi/browsing_context/types/browsing_context.{
  type BrowsingContext, BrowsingContext,
}
import butterbidi/browsing_context/types/locator.{type Locator}
import butterbidi/script/types/remote_reference
import butterbidi/script/types/remote_value
import butterbidi/script/types/serialization_options.{type SerializationOptions}
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

pub fn new(context: BrowsingContext, locator: Locator) -> LocateNodesParameters {
  LocateNodesParameters(
    locator:,
    context:,
    max_node_count: None,
    serialization_options: None,
    start_nodes: None,
  )
}

///
/// Creates a new `LocateNodesParameters` type without a context.
///
pub fn new_without_context(locator: Locator) -> LocateNodesParameters {
  LocateNodesParameters(
    locator:,
    context: BrowsingContext(id: uuid.nil),
    max_node_count: None,
    serialization_options: None,
    start_nodes: None,
  )
}

pub fn with_context(
  locate_nodes_parameters: LocateNodesParameters,
  context: BrowsingContext,
) -> LocateNodesParameters {
  LocateNodesParameters(..locate_nodes_parameters, context: context)
}

pub fn with_max_node_count(
  locate_nodes_parameters: LocateNodesParameters,
  max_node_count: Int,
) -> LocateNodesParameters {
  LocateNodesParameters(
    ..locate_nodes_parameters,
    max_node_count: Some(max_node_count),
  )
}

pub fn with_serialization_options(
  locate_nodes_parameters: LocateNodesParameters,
  serialization_options: SerializationOptions,
) -> LocateNodesParameters {
  LocateNodesParameters(
    ..locate_nodes_parameters,
    serialization_options: Some(serialization_options),
  )
}

pub fn with_start_nodes(
  locate_nodes_parameters: LocateNodesParameters,
  start_nodes: List(remote_reference.SharedReference),
) -> LocateNodesParameters {
  LocateNodesParameters(
    ..locate_nodes_parameters,
    start_nodes: Some(start_nodes),
  )
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
