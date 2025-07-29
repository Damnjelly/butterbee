////
////  ▗▄▄▖▗▞▀▘ ▄▄▄ ▄ ▄▄▄▄▗▄▄▄▖
//// ▐▌   ▝▚▄▖█    ▄ █   █ █  
////  ▝▀▚▖    █    █ █▄▄▄▀ █  
//// ▗▄▄▞▘         █ █     █  
////                 ▀        
////
//// The script module contains commands and events relating to script realms and execution.
////
//// https://w3c.github.io/webdriver-bidi/#module-script

import butterbee/internal/decoders
import gleam/dict.{type Dict}
import gleam/dynamic/decode
import gleam/json.{type Json}
import gleam/list
import gleam/option.{type Option, Some}
import youid/uuid.{type Uuid}

pub type IncludeShadowTree {
  IncludeShadowTreeNone
  IncludeShadowTreeOpen
  IncludeShadowTreeAll
}

fn include_shadow_tree_to_json(include_shadow_tree: IncludeShadowTree) -> Json {
  case include_shadow_tree {
    IncludeShadowTreeNone -> json.string("none")
    IncludeShadowTreeOpen -> json.string("open")
    IncludeShadowTreeAll -> json.string("all")
  }
}

/// Note: is not actually optional and nullable
pub type SerializationOptions {
  SerializationOptions(
    max_dom_depth: Option(Option(Int)),
    max_object_depth: Option(Option(Int)),
    include_shadow_tree: Option(Option(IncludeShadowTree)),
  )
}

pub fn serialization_options_to_json(
  serialization_options: SerializationOptions,
) -> List(#(String, json.Json)) {
  let SerializationOptions(
    max_dom_depth:,
    max_object_depth:,
    include_shadow_tree:,
  ) = serialization_options
  let max_dom_depth = case max_dom_depth {
    option.None -> []
    Some(value) -> [
      #("max_dom_depth", case value {
        option.None -> json.null()
        Some(value) -> json.int(value)
      }),
    ]
  }
  let max_object_depth = case max_object_depth {
    option.None -> []
    Some(value) -> [
      #("max_object_depth", case value {
        option.None -> json.null()
        Some(value) -> json.int(value)
      }),
    ]
  }
  let include_shadow_tree = case include_shadow_tree {
    option.None -> []
    Some(value) -> [
      #("include_shadow_tree", case value {
        option.None -> json.null()
        Some(value) -> include_shadow_tree_to_json(value)
      }),
    ]
  }
  [
    #(
      "serialization_options",
      json.object(
        []
        |> list.append(max_dom_depth)
        |> list.append(max_object_depth)
        |> list.append(include_shadow_tree),
      ),
    ),
  ]
}

pub type NodeRemoteValue {
  NodeRemoteValue(
    remote_type: String,
    shared_id: Option(Uuid),
    handle: Option(Uuid),
    internal_id: Option(String),
    value: Option(NodeProperties),
  )
}

pub fn node_remote_value_decoder() -> decode.Decoder(NodeRemoteValue) {
  use remote_type <- decode.field("type", decode.string)
  use shared_id <- decode.optional_field(
    "sharedId",
    option.None,
    decode.optional(decoders.uuid()),
  )
  use handle <- decode.optional_field(
    "handle",
    option.None,
    decode.optional(decoders.uuid()),
  )
  use internal_id <- decode.optional_field(
    "internalId",
    option.None,
    decode.optional(decode.string),
  )
  use value <- decode.optional_field(
    "value",
    option.None,
    decode.optional(node_properties_decoder()),
  )
  decode.success(NodeRemoteValue(
    remote_type:,
    shared_id:,
    handle: handle,
    internal_id: internal_id,
    value:,
  ))
}

pub type Mode {
  ModeOpen
  ModeClosed
}

fn mode_decoder() -> decode.Decoder(Mode) {
  use variant <- decode.then(decode.string)
  case variant {
    "open" -> decode.success(ModeOpen)
    "closed" -> decode.success(ModeClosed)
    _ -> decode.failure(ModeOpen, "Mode")
  }
}

pub type SharedReference {
  SharedReference(shared_id: Uuid, handle: Option(Uuid))
}

pub fn shared_reference_to_json(shared_reference: SharedReference) -> Json {
  let SharedReference(shared_id:, handle:) = shared_reference
  json.object([
    #("sharedId", json.string(uuid.to_string(shared_id))),
    #("handle", case handle {
      option.None -> json.null()
      Some(value) -> json.string(uuid.to_string(value))
    }),
  ])
}

pub type NodeProperties {
  NodeProperties(
    node_type: Int,
    child_node_count: Int,
    attributes: Option(Dict(String, String)),
    children: Option(List(NodeRemoteValue)),
    local_name: Option(String),
    mode: Option(Mode),
    node_value: Option(String),
    shadow_root: Option(Option(NodeRemoteValue)),
  )
}

fn node_properties_decoder() -> decode.Decoder(NodeProperties) {
  use node_type <- decode.field("nodeType", decode.int)
  use child_node_count <- decode.field("childNodeCount", decode.int)
  use attributes <- decode.optional_field(
    "attributes",
    option.None,
    decode.optional(decode.dict(decode.string, decode.string)),
  )
  use children <- decode.optional_field(
    "children",
    option.None,
    decode.optional(decode.list(node_remote_value_decoder())),
  )
  use local_name <- decode.optional_field(
    "localName",
    option.None,
    decode.optional(decode.string),
  )
  use mode <- decode.optional_field(
    "mode",
    option.None,
    decode.optional(mode_decoder()),
  )
  use node_value <- decode.optional_field(
    "nodeValue",
    option.None,
    decode.optional(decode.string),
  )
  use shadow_root <- decode.optional_field(
    "shadow_root",
    option.None,
    decode.optional(decode.optional(node_remote_value_decoder())),
  )
  decode.success(NodeProperties(
    node_type:,
    child_node_count:,
    attributes:,
    children:,
    local_name:,
    mode:,
    node_value:,
    shadow_root:,
  ))
}
