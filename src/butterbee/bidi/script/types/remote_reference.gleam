import gleam/json.{type Json}
import gleam/option.{type Option, None, Some}
import youid/uuid.{type Uuid}

pub type RemoteReference

pub type SharedReference {
  SharedReference(shared_id: Uuid, handle: Option(Uuid))
}

pub fn shared_reference_to_json(shared_reference: SharedReference) -> Json {
  let SharedReference(shared_id:, handle:) = shared_reference
  json.object([
    #("sharedId", json.string(uuid.to_string(shared_id))),
    #("handle", case handle {
      None -> json.null()
      Some(value) -> json.string(uuid.to_string(value))
    }),
  ])
}
