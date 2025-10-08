import butterbidi/script/types/primitive_protocol_value.{
  type PrimitiveProtocolValue, BigInt, BigIntValue, Boolean, BooleanValue, Null,
  NullValue, Number, NumberValue, String, StringValue, Undefined, UndefinedValue,
}
import gleam/dict
import gleam/dynamic/decode.{type Decoder}
import gleam/option.{type Option, None}
import internal/decoders
import logging
import youid/uuid.{type Uuid}

pub type RemoteValue {
  PrimitiveProtocol(PrimitiveProtocolValue)
  NodeRemote(NodeRemoteValue)
}

pub fn remote_value_decoder() -> Decoder(RemoteValue) {
  use remote_type <- decode.field("type", decode.string)
  case remote_type {
    "undefined" ->
      decode.success(PrimitiveProtocol(Undefined(UndefinedValue(remote_type:))))
    "null" -> decode.success(PrimitiveProtocol(Null(NullValue(remote_type:))))
    "string" -> {
      use value <- decode.field("value", decode.string)
      decode.success(
        PrimitiveProtocol(String(StringValue(remote_type:, value:))),
      )
    }
    "number" -> {
      use value <- decode.field("value", decode.dynamic)
      let value = primitive_protocol_value.number_value_classifier(value)
      decode.success(
        PrimitiveProtocol(Number(NumberValue(remote_type:, value:))),
      )
    }
    "boolean" -> {
      use value <- decode.field("value", decode.bool)
      decode.success(
        PrimitiveProtocol(Boolean(BooleanValue(remote_type:, value:))),
      )
    }
    "bigint" -> {
      use value <- decode.field("value", decode.string)
      decode.success(
        PrimitiveProtocol(BigInt(BigIntValue(remote_type:, value:))),
      )
    }
    "node" -> {
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
      decode.success(
        NodeRemote(NodeRemoteValue(
          remote_type:,
          shared_id:,
          handle:,
          internal_id:,
          value:,
        )),
      )
    }
    _ -> {
      logging.log(logging.Warning, "Unknown remote value type: " <> remote_type)
      panic as "Unknown remote value type"
    }
  }
}

pub fn remote_value_to_string(remote_value: RemoteValue) -> String {
  case remote_value {
    PrimitiveProtocol(value) -> primitive_protocol_value.to_string(value)
    NodeRemote(value) -> {
      logging.log(
        logging.Debug,
        "Expected PrimitiveProtocol, got NodeRemote. Returning remote_type",
      )
      value.remote_type
    }
  }
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

pub fn node_remote_value_decoder() -> Decoder(NodeRemoteValue) {
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
    handle:,
    internal_id:,
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

fn node_properties_decoder() -> Decoder(NodeProperties) {
  use node_type <- decode.field("nodeType", decode.int)
  use child_node_count <- decode.field("childNodeCount", decode.int)
  use attributes <- decode.optional_field(
    "attributes",
    None,
    decode.optional(decode.dict(decode.string, decode.string)),
  )
  use children <- decode.optional_field(
    "children",
    None,
    decode.optional(decode.list(node_remote_value_decoder())),
  )
  use local_name <- decode.optional_field(
    "localName",
    None,
    decode.optional(decode.string),
  )
  use mode <- decode.optional_field(
    "mode",
    None,
    decode.optional(mode_decoder()),
  )
  use node_value <- decode.optional_field(
    "nodeValue",
    None,
    decode.optional(decode.string),
  )
  use shadow_root <- decode.optional_field(
    "shadow_root",
    None,
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

fn mode_decoder() -> Decoder(Mode) {
  use variant <- decode.then(decode.string)
  case variant {
    "open" -> decode.success(ModeOpen)
    "closed" -> decode.success(ModeClosed)
    _ -> decode.failure(ModeOpen, "Mode")
  }
}
