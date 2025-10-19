import butterbee/by
import butterbee/get
import butterbee/webdriver

const comments_field_id = "textarea#comments"

pub fn comments_field(
  driver: webdriver.WebDriver(state),
  action: fn(_) -> webdriver.WebDriver(new_state),
) {
  driver
  |> get.node(by.css(comments_field_id))
  |> action
}
