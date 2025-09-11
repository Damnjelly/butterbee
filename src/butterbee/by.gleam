////
//// The by module contains functions to specify the type of locator to use to query for webelements
//// 

import butterbee/bidi/browsing_context/types/locator.{type Locator}

pub fn xpath(value: String) -> Locator {
  locator.new_xpath_locator(value)
}

pub fn css(value: String) -> Locator {
  locator.new_css_locator(value)
}

pub fn inner_text(value: String) -> Locator {
  locator.new_inner_text_locator(value)
  |> locator.with_match_type(locator.Partial)
}
