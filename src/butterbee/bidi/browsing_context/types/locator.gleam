import butterbee/bidi/browsing_context/types/browsing_context
import gleam/json.{type Json}
import gleam/option.{type Option, None, Some}

pub type Locator {
  AccessibilityLocator(name: Option(String), role: Option(String))
  CssLocator(value: String)
  ContextLocator(context: browsing_context.BrowsingContext)
  InnerTextLocator(
    value: String,
    ignore_case: Option(Bool),
    match_type: Option(MatchType),
    max_depth: Option(Int),
  )
  XPathLocator(value: String)
}

pub fn locator_to_json(locator: Locator) -> Json {
  case locator {
    AccessibilityLocator(name:, role:) ->
      json.object([
        #("type", json.string("accessibility")),
        #("name", case name {
          None -> json.null()
          Some(value) -> json.string(value)
        }),
        #("role", case role {
          None -> json.null()
          Some(value) -> json.string(value)
        }),
      ])
    CssLocator(value:) ->
      json.object([
        #("type", json.string("css")),
        #("value", json.string(value)),
      ])
    ContextLocator(context: _) ->
      json.object([
        #("type", json.string("context")),
        #("context", todo as "Encoder for BrowsingContext"),
      ])
    InnerTextLocator(value:, ignore_case:, match_type:, max_depth:) ->
      json.object([
        #("type", json.string("innerText")),
        #("value", json.string(value)),
        #("ignore_case", case ignore_case {
          None -> json.null()
          Some(value) -> json.bool(value)
        }),
        #("match_type", case match_type {
          None -> json.null()
          Some(value) -> json.string(match_type_to_string(value))
        }),
        #("max_depth", case max_depth {
          None -> json.null()
          Some(value) -> json.int(value)
        }),
      ])
    XPathLocator(value:) ->
      json.object([
        #("type", json.string("xpath")),
        #("value", json.string(value)),
      ])
  }
}

pub type MatchType {
  Full
  Partial
}

fn match_type_to_string(match_type: MatchType) -> String {
  case match_type {
    Full -> "full"
    Partial -> "partial"
  }
}
