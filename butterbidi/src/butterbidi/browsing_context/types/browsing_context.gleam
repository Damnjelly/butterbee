import gleam/dynamic/decode
import gleam/json
import internal/decoders
import youid/uuid.{type Uuid}

pub type BrowsingContext {
  BrowsingContext(id: Uuid)
}

pub fn browsing_context_to_json(browsing_context: BrowsingContext) -> json.Json {
  let BrowsingContext(id:) = browsing_context
  json.object([#("id", json.string(uuid.to_string(id)))])
}

pub fn browsing_context_decoder() -> decode.Decoder(BrowsingContext) {
  use id <- decode.then(decoders.uuid())
  decode.success(BrowsingContext(id:))
}
