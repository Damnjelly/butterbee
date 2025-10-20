import butterbee/by
import butterbee/driver
import butterbee/page_module/node_element
import butterbee/page_module/node_list.{type NodeList}
import butterbee/page_module/node_select
import butterbee/webdriver.{type WebDriver}
import simplifile

pub fn goto(driver: WebDriver(state)) {
  let file_path = case simplifile.current_directory() {
    Ok(cwd) -> cwd <> "/assets/test_page.html"
    Error(_) -> panic as "Could not get current working directory"
  }
  driver.goto(driver, "file://" <> file_path)
}

const username_field_locator = "input#username"

pub fn username_field(
  driver: WebDriver(state),
  action: fn(_) -> WebDriver(new_state),
) {
  node_element.define(field: by.css(username_field_locator))
  |> node_element.perform_action(driver, action)
}

const email_field_locator = "input#email"

pub fn email_field(
  driver: WebDriver(state),
  action: fn(_) -> WebDriver(new_state),
) {
  node_element.define(field: by.css(email_field_locator))
  |> node_element.perform_action(driver, action)
}

const age_field_locator = "input#age"

pub fn age_field(
  driver: WebDriver(state),
  action: fn(_) -> WebDriver(new_state),
) {
  node_element.define(field: by.css(age_field_locator))
  |> node_element.perform_action(driver, action)
}

const country_dropdown_locator = "select#country"

pub fn country_dropdown(
  driver: WebDriver(state),
  action: fn(_) -> WebDriver(new_state),
) {
  node_select.define(field: by.css(country_dropdown_locator))
  |> node_select.perform_action(driver, action)
}

const comments_field_locator = "textarea#comments"

pub fn comments_field(
  driver: WebDriver(state),
  action: fn(_) -> WebDriver(new_state),
) {
  node_element.define(field: by.css(comments_field_locator))
  |> node_element.perform_action(driver, action)
}

const submit_form_button_locator = "button#submitBtn"

pub fn submit_form_button(
  driver: WebDriver(state),
  action: fn(_) -> WebDriver(new_state),
) {
  node_element.define(field: by.css(submit_form_button_locator))
  |> node_element.perform_action(driver, action)
}

const change_color_button_locator = "button#changeColorBtn"

pub fn change_color_button(
  driver: WebDriver(state),
  action: fn(_) -> WebDriver(new_state),
) {
  node_element.define(field: by.css(change_color_button_locator))
  |> node_element.perform_action(driver, action)
}

const clear_form_button_locator = "button#clearBtn"

pub fn clear_form_button(
  driver: WebDriver(state),
  action: fn(_) -> WebDriver(new_state),
) {
  node_element.define(field: by.css(clear_form_button_locator))
  |> node_element.perform_action(driver, action)
}

const test_list_locator = "//ul[@id='testList']"

const test_list_item_locator = "/li"

pub fn test_list(
  driver: WebDriver(state),
  on_element: NodeList,
  action: fn(_) -> WebDriver(new_state),
) {
  node_list.define(
    list: by.css(test_list_locator),
    list_item: by.css(test_list_item_locator),
  )
  |> node_list.perform_action(driver, on_element, action)
}

const test_link_locator = "a#externalLink"

pub fn test_link(
  driver: WebDriver(state),
  action: fn(_) -> WebDriver(new_state),
) {
  node_element.define(field: by.css(test_link_locator))
  |> node_element.perform_action(driver, action)
}

const disabled_link_locator = "a#disabledLink"

pub fn disabled_link(
  driver: WebDriver(state),
  action: fn(_) -> WebDriver(new_state),
) {
  node_element.define(field: by.css(disabled_link_locator))
  |> node_element.perform_action(driver, action)
}
