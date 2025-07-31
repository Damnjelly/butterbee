import gleam/json.{type Json}
import gleam/list
import gleam/option.{type Option, None, Some}
import youid/uuid.{type Uuid}

pub type RemoteReference {
  Shared(SharedReference)
  //TODO: RemoteObject(RemoteObjectReference)
}

pub fn remote_reference_to_json(remote_reference: RemoteReference) -> Json {
  case remote_reference {
    Shared(shared_reference) -> shared_reference_to_json(shared_reference)
    //TODO: RemoteObject(remote_object_reference) ->
    //   remote_object_reference_to_json(
    //     remote_object_reference,
    //   )
  }
}

pub type SharedReference {
  SharedReference(shared_id: Uuid, handle: Option(Uuid))
}

pub fn shared_reference_to_json(shared_reference: SharedReference) -> Json {
  let SharedReference(shared_id:, handle:) = shared_reference

  let handle = case handle {
    None -> []
    Some(value) -> [#("handle", json.string(uuid.to_string(value)))]
  }

  json.object(
    [#("sharedId", json.string(uuid.to_string(shared_id)))]
    |> list.append(handle),
  )
}
