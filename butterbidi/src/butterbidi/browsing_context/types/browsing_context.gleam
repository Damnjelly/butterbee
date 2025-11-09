////
//// [w3c link](https://w3c.github.io/webdriver-bidi/#type-browsingContext-Browsingcontext)
////

import gleam/dynamic/decode
import gleam/json

pub type BrowsingContext {
  BrowsingContext(id: String)
}

pub fn browsing_context_to_json(browsing_context: BrowsingContext) -> json.Json {
  let BrowsingContext(id:) = browsing_context
  json.object([#("id", json.string(id))])
}

pub fn browsing_context_decoder() -> decode.Decoder(BrowsingContext) {
  use id <- decode.then(decode.string)
  decode.success(BrowsingContext(id:))
}
