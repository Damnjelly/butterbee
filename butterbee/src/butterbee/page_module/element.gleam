//// Define elements for page module using this module.
////
//// Example:
////
//// ```gleam
//// import butterbee/page_module/element
////
//// pub fn submit_button(
////   driver: WebDriver(state),
////   action: fn(_) -> WebDriver(new_state),
//// ) {
////   element.define(field: by.css("button#submit"))
////   |> element.perform_action(driver, action)
//// }
//// ```
////
//// For a more complete example, see the [`page module`](https://hexdocs.pm/butterbee/page-modules) guide.

import butterbee/get
import butterbee/webdriver.{type WebDriver}
import butterbidi/browsing_context/types/locator.{type Locator}

/// Define an element for a page module.
pub fn define(field locator: Locator) -> Locator {
  locator
}

/// Perform an action on the defined element.
pub fn perform_action(
  locator: Locator,
  driver: WebDriver(state),
  action: fn(_) -> WebDriver(new_state),
) -> WebDriver(new_state) {
  get.node(driver, locator)
  |> action
}
