import butterbee/by
import butterbee/query
import butterbee/webdriver

pub fn comments_field(webdriver: webdriver.WebDriver) {
  webdriver
  |> query.node(by.css("textarea#comments"))
}
