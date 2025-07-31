import butterbee/bidi/browsing_context/types/locator
import gleam/option

pub type By {
  By(locator: locator.Locator)
}

pub fn xpath(value: String) -> By {
  locator.XPathLocator(value) |> By
}

pub fn css(value: String) -> By {
  locator.CssLocator(value) |> By
}

pub fn inner_text(value: String) -> By {
  locator.InnerTextLocator(
    value,
    option.None,
    option.Some(locator.Full),
    option.None,
  )
  |> By
}
