import butterbee/bidi/script/types/remote_reference.{type RemoteReference}

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
