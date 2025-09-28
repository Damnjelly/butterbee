////
//// The by module contains functions to specify the type of locator to use
//// to query for webelements
//// 

import butterbee/bidi/browsing_context/types/locator.{
  type Locator, type MatchType,
}

pub fn xpath(value: String) -> Locator {
  locator.new_xpath_locator(value)
}

pub fn css(value: String) -> Locator {
  locator.new_css_locator(value)
}

pub fn inner_text(value: String, match_type: MatchType) -> Locator {
  locator.new_inner_text_locator(value)
  |> locator.with_match_type(match_type)
}
