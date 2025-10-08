import butterbidi/script/types/remote_reference
import gleam/json.{type Json}

pub type ElementOrigin {
  ElementOrigin(element: remote_reference.SharedReference)
}

pub fn element_origin_to_json(element_origin: ElementOrigin) -> Json {
  let ElementOrigin(element:) = element_origin
  json.object([
    #("type", json.string("element")),
    #("element", remote_reference.shared_reference_to_json(element)),
  ])
}
