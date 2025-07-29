import butterbee/internal/bidi/browsing_context
import gleam/option

pub type By {
  By(locator: browsing_context.Locator)
}

pub fn xpath(value: String) -> By {
  browsing_context.XPathLocator(value) |> By
}

pub fn css(value: String) -> By {
  browsing_context.CssLocator(value) |> By
}

pub fn inner_text(value: String) -> By {
  browsing_context.InnerTextLocator(
    value,
    option.None,
    option.Some(browsing_context.Full),
    option.None,
  )
  |> By
}
