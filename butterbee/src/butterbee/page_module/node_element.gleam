import butterbee/get
import butterbee/webdriver.{type WebDriver}
import butterbidi/browsing_context/types/locator.{type Locator}

pub fn define(field locator: Locator) -> Locator {
  locator
}

pub fn perform_action(
  locator: Locator,
  driver: WebDriver(state),
  action: fn(_) -> WebDriver(new_state),
) -> WebDriver(new_state) {
  get.node(driver, locator)
  |> action
}
