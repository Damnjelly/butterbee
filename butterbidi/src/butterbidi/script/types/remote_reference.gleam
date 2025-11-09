import gleam/json.{type Json}
import gleam/list
import gleam/option.{type Option, None, Some}

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

pub fn remote_reference_from_id(shared_id: String) -> RemoteReference {
  Shared(shared_reference_from_id(shared_id))
}

pub type SharedReference {
  SharedReference(shared_id: String, handle: Option(String))
}

pub fn shared_reference_to_json(shared_reference: SharedReference) -> Json {
  let SharedReference(shared_id:, handle:) = shared_reference

  let handle = case handle {
    None -> []
    Some(value) -> [#("handle", json.string(value))]
  }

  json.object(
    [#("sharedId", json.string(shared_id))]
    |> list.append(handle),
  )
}

/// Creates a new shared reference from a shared id
pub fn shared_reference_from_id(shared_id: String) -> SharedReference {
  SharedReference(shared_id, None)
}

pub fn shared_reference_with_handle(
  shared_reference: SharedReference,
  handle: String,
) -> SharedReference {
  SharedReference(..shared_reference, handle: Some(handle))
}
