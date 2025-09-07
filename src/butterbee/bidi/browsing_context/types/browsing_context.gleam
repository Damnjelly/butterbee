import butterbee/internal/decoders
import gleam/dynamic/decode
import youid/uuid.{type Uuid}

pub type BrowsingContext {
  BrowsingContext(id: Uuid)
}

pub fn browsing_context_decoder() -> decode.Decoder(BrowsingContext) {
  use id <- decode.then(decoders.uuid())
  decode.success(BrowsingContext(id:))
}
