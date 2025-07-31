import butterbee/internal/decoders
import gleam/dynamic/decode
import youid/uuid.{type Uuid}

pub type BrowsingContext {
  BrowsingContext(
    //TODO: children: List(BrowsingContext),
    //TODO: client_window: ClientWindow,
    context: Uuid,
    //TODO: original_opener: BrowsingContext,
    url: String,
    //TODO: user_context: UserContext,
    //TODO: parent: Option(BrowsingContext),
  )
}

pub fn browsing_context_decoder() -> decode.Decoder(BrowsingContext) {
  // WARN: This results into an infinite loop
  // use children <- decode.field(
  //   "children",
  //   decode.list(browsing_context_decoder()),
  // )
  use context <- decode.field("context", decoders.uuid())
  use url <- decode.field("url", decode.string)
  decode.success(BrowsingContext(context:, url:))
}
