import butterbee/action
import butterbee/by
import butterbee/get
import butterbee/internal/error
import butterbee/key
import butterbee/node
import butterbee/webdriver.{type WebDriver}
import butterbidi/browsing_context/types/locator.{type Locator}
import butterbidi/script/types/remote_value
import gleam/list
import gleam/result

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

pub fn option(
  option: String,
) -> fn(WebDriver(remote_value.NodeRemoteValue)) ->
  WebDriver(remote_value.NodeRemoteValue) {
  fn(driver: WebDriver(remote_value.NodeRemoteValue)) {
    case driver.state {
      Error(error) -> Error(error)
      Ok(node_remote_value) -> {
        let driver =
          driver
          |> webdriver.with_state(Ok(node_remote_value))
          |> get.nodes_from_node(by.xpath("//option"))
          |> node.get_all(node.values())

        use strings <- result.try({ driver.state })

        case list.contains(strings, option) {
          False -> Error(error.NoNodeFound)
          True -> Ok(node_remote_value)
        }
      }
    }
    |> webdriver.map_state(driver)
    |> get.from_node(by.xpath("//option[text()='" <> option <> "']"))
    |> node.do(action.click(key.LeftClick))
  }
}
