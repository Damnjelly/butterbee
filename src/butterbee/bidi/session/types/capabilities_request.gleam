import butterbee/bidi/session/types/capability_request.{
  type CapabilityRequest, capability_request_to_json,
}
import gleam/json.{type Json}
import gleam/list
import gleam/option.{type Option, None, Some}

pub type CapabilitiesRequest {
  CapabilitiesRequest(
    always_match: Option(CapabilityRequest),
    first_match: Option(List(CapabilityRequest)),
  )
}

pub fn capabilities_request_to_json(
  capabilities_request: CapabilitiesRequest,
) -> Json {
  let CapabilitiesRequest(always_match:, first_match:) = capabilities_request
  let always_match = case always_match {
    None -> []
    Some(value) -> [#("always_match", capability_request_to_json(value))]
  }
  let first_match = case first_match {
    None -> []
    Some(value) -> [
      #("first_match", json.array(value, capability_request_to_json)),
    ]
  }

  json.object([
    #(
      "capabilities",
      json.object(
        []
        |> list.append(always_match)
        |> list.append(first_match),
      ),
    ),
  ])
}
