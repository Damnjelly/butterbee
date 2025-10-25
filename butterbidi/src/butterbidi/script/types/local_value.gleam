import butterbidi/script/types/primitive_protocol_value.{
  type PrimitiveProtocolValue, primitive_protocol_value_to_json,
}
import butterbidi/script/types/remote_reference.{
  type RemoteReference, remote_reference_to_json,
}
import butterbidi/script/types/remote_value
import butterlib/log
import gleam/json.{type Json}
import gleam/option.{None, Some}

pub type LocalValue {
  RemoteReference(RemoteReference)
  PrimitiveProtocol(PrimitiveProtocolValue)
  //TODO: Channel(ChannelValue)
  ArrayLocal(ArrayLocalValue)
  //TODO: DateLocal(DateLocalValue)
  //TODO: MapLocal(MapLocalValue)
  //TODO: ObjectLocal(ObjectLocalValue)
  //TODO: RegExpLocal(RegExpLocalValue)
  //TODO: SetLocal(SetLocalValue)
}

pub fn local_value_to_json(local_value: LocalValue) -> Json {
  case local_value {
    RemoteReference(remote_reference) ->
      remote_reference_to_json(remote_reference)
    PrimitiveProtocol(primitive_protocol_value) ->
      primitive_protocol_value_to_json(primitive_protocol_value)
    //TODO: Channel(channel_value) ->
    //   channel_value.channel_value_to_json(channel_value)
    ArrayLocal(array_local_value) ->
      array_local_value_to_json(array_local_value)
    //TODO: DateLocal(date_local_value) ->
    //   date_local_value.date_local_value_to_json(date_local_value)
    //TODO: MapLocal(map_local_value) ->
    //   map_local_value.map_local_value_to_json(map_local_value)
    //TODO: ObjectLocal(object_local_value) ->
    //   object_local_value.object_local_value_to_json(object_local_value)
    //TODO: RegExpLocal(reg_exp_local_value) ->
    //   reg_exp_local_value.reg_exp_local_value_to_json(reg_exp_local_value)
    //TODO: SetLocal(set_local_value) ->
    //   set_local_value.set_local_value_to_json(set_local_value)
  }
}

pub type ArrayLocalValue {
  ArrayLocalValue(local_type: String, value: List(LocalValue))
}

pub fn array_local_value_to_json(array_local_value: ArrayLocalValue) -> Json {
  let ArrayLocalValue(local_type, value) = array_local_value
  json.object([
    #("type", json.string(local_type)),
    #("value", json.array(value, local_value_to_json)),
  ])
}

pub fn int(int: Int) -> LocalValue {
  PrimitiveProtocol(primitive_protocol_value.int(int))
}

pub fn float(float: Float) -> LocalValue {
  PrimitiveProtocol(primitive_protocol_value.float(float))
}

pub fn string(string: String) -> LocalValue {
  PrimitiveProtocol(primitive_protocol_value.string(string))
}

pub fn boolean(boolean: Bool) -> LocalValue {
  PrimitiveProtocol(primitive_protocol_value.boolean(boolean))
}

pub fn array(array: List(LocalValue)) -> LocalValue {
  ArrayLocal(ArrayLocalValue("array", array))
}

pub fn node(node: remote_value.NodeRemoteValue) -> LocalValue {
  case node.shared_id {
    None ->
      log.error_and_continue(
        "Node does not have shared id",
        PrimitiveProtocol(primitive_protocol_value.undefined()),
      )
    Some(shared_id) ->
      shared_id
      |> remote_reference.remote_reference_from_id()
      |> RemoteReference
  }
}

pub fn remote_reference(remote_reference: RemoteReference) -> LocalValue {
  RemoteReference(remote_reference)
}
