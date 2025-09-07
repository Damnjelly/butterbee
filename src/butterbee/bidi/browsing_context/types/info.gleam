import butterbee/bidi/browsing_context/types/browsing_context.{
  type BrowsingContext,
}
import butterbee/internal/decoders
import gleam/dynamic/decode
import gleam/option.{type Option}
import youid/uuid.{type Uuid}

pub type InfoList {
  InfoList(list: List(Info))
}

pub fn info_list_decoder() -> decode.Decoder(InfoList) {
  use list <- decode.then(decode.list(info_decoder()))
  decode.success(InfoList(list:))
}

pub type Info {
  Info(
    children: Option(InfoList),
    //TODO: client_window: browser.ClientWindow,
    context: BrowsingContext,
    original_opener: Option(BrowsingContext),
    url: String,
    //TODO: user_context: browser.UserContext,
    parent: Option(Option(BrowsingContext)),
  )
}

pub fn info_decoder() -> decode.Decoder(Info) {
  use <- decode.recursive
  use children <- decode.field("children", decode.optional(info_list_decoder()))
  use context <- decode.field(
    "context",
    browsing_context.browsing_context_decoder(),
  )
  use original_opener <- decode.field(
    "originalOpener",
    decode.optional(browsing_context.browsing_context_decoder()),
  )
  use url <- decode.field("url", decode.string)
  use parent <- decode.optional_field(
    "parent",
    option.None,
    decode.optional(
      decode.optional(browsing_context.browsing_context_decoder()),
    ),
  )
  decode.success(Info(children:, context:, original_opener:, url:, parent:))
}
