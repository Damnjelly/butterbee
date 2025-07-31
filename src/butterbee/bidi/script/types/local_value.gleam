import butterbee/bidi/script/types/remote_reference.{type RemoteReference}
import gleam/json.{type Json}

pub type LocalValue {
  RemoteReference(RemoteReference)
  //TODO: PrimitiveProtocol(PrimitiveProtocolValue)
  //TODO: Channel(ChannelValue)
  //TODO: ArrayLocal(ArrayLocalValue)
  //TODO: DateLocal(DateLocalValue)
  //TODO: MapLocal(MapLocalValue)
  //TODO: ObjectLocal(ObjectLocalValue)
  //TODO: RegExpLocal(RegExpLocalValue)
  //TODO: SetLocal(SetLocalValue)
}

pub fn local_value_to_json(local_value: LocalValue) -> Json {
  case local_value {
    RemoteReference(remote_reference) ->
      remote_reference.remote_reference_to_json(remote_reference)
    //TODO: PrimitiveProtocol(primitive_protocol_value) ->
    //   primitive_protocol_value.primitive_protocol_value_to_json(primitive_protocol_value)
    //TODO: Channel(channel_value) ->
    //   channel_value.channel_value_to_json(channel_value)
    //TODO: ArrayLocal(array_local_value) ->
    //   array_local_value.array_local_value_to_json(array_local_value)
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
