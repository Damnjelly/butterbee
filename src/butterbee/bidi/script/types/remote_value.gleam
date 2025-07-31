import butterbee/internal/decoders
import gleam/dict
import gleam/dynamic/decode
import gleam/option.{type Option, None}
import youid/uuid.{type Uuid}

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
    None,
    decode.optional(decoders.uuid()),
  )
  use handle <- decode.optional_field(
    "handle",
    None,
    decode.optional(decoders.uuid()),
  )
  use internal_id <- decode.optional_field(
    "internalId",
    None,
    decode.optional(decode.string),
  )
  use value <- decode.optional_field(
    "value",
    None,
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

pub type NodeProperties {
  NodeProperties(
    node_type: Int,
    child_node_count: Int,
    attributes: Option(dict.Dict(String, String)),
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
