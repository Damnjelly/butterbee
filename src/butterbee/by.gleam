////
//// The by module contains functions to specify locators for use with the query module
//// 

import butterbee/bidi/browsing_context/types/locator.{type Locator}
import gleam/option

pub fn xpath(value: String) -> Locator {
  locator.XPathLocator(value)
}

pub fn css(value: String) -> Locator {
  locator.CssLocator(value)
}

pub fn inner_text(value: String) -> Locator {
  locator.InnerTextLocator(
    value,
    option.None,
    option.Some(locator.Full),
    option.None,
  )
}
