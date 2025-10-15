import butterbidi/browsing_context/types/browsing_context.{
  type BrowsingContext, browsing_context_to_json,
}
import gleam/json.{type Json}
import gleam/option.{type Option, None, Some}

pub type Locator {
  AccessibilityLocator(name: Option(String), role: Option(String))
  CssLocator(value: String)
  ContextLocator(context: BrowsingContext)
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
    ContextLocator(context:) ->
      json.object([
        #("type", json.string("context")),
        #("context", browsing_context_to_json(context)),
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

pub fn new_context_locator(context: browsing_context.BrowsingContext) -> Locator {
  ContextLocator(context)
}

pub fn new_accessibility_locator(
  name: Option(String),
  role: Option(String),
) -> Locator {
  AccessibilityLocator(name, role)
}

pub fn new_css_locator(value: String) -> Locator {
  CssLocator(value)
}

pub fn new_inner_text_locator(value: String) -> Locator {
  InnerTextLocator(value, None, None, None)
}

pub fn with_ignore_case(locator: Locator) -> Locator {
  case locator {
    InnerTextLocator(value, _, match_type, max_depth) ->
      InnerTextLocator(value, Some(True), match_type, max_depth)
    _ -> locator
  }
}

pub fn with_match_type(locator: Locator, match_type: MatchType) -> Locator {
  case locator {
    InnerTextLocator(value, ignore_case, _, max_depth) ->
      InnerTextLocator(value, ignore_case, Some(match_type), max_depth)
    _ -> locator
  }
}

pub fn with_max_depth(locator: Locator, max_depth: Int) -> Locator {
  case locator {
    InnerTextLocator(value, ignore_case, match_type, _) ->
      InnerTextLocator(value, ignore_case, match_type, Some(max_depth))
    _ -> locator
  }
}

pub fn new_xpath_locator(value: String) -> Locator {
  XPathLocator(value)
}
