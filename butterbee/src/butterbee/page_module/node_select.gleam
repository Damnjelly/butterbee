import butterbee/by
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
  |> get.nodes_from_node(by.xpath("/option"))
  |> action
}

pub fn option(option: String) -> fn(WebDriver(state)) -> WebDriver(new_state) {
  todo
}
