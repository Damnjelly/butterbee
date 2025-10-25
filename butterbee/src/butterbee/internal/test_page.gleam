import butterbee/by
import butterbee/driver
import butterbee/page_module/element
import butterbee/page_module/list_element.{type NodeList}
import butterbee/page_module/select_element
import butterbee/page_module/table_element.{type NodeTable}
import butterbee/webdriver.{type WebDriver}
import simplifile

pub fn goto(driver: WebDriver(state)) {
  let file_path = case simplifile.current_directory() {
    Ok(cwd) -> cwd <> "/assets/test_page.html"
    Error(_) -> panic as "Could not get current working directory"
  }
  driver.goto(driver, "file://" <> file_path)
}

pub fn body(driver: WebDriver(state), action: fn(_) -> WebDriver(new_state)) {
  element.define(field: by.xpath("//body"))
  |> element.perform_action(driver, action)
}

pub fn username_field(
  driver: WebDriver(state),
  action: fn(_) -> WebDriver(new_state),
) {
  element.define(field: by.css("input#username"))
  |> element.perform_action(driver, action)
}

pub fn email_field(
  driver: WebDriver(state),
  action: fn(_) -> WebDriver(new_state),
) {
  element.define(field: by.css("input#email"))
  |> element.perform_action(driver, action)
}

pub fn age_field(
  driver: WebDriver(state),
  action: fn(_) -> WebDriver(new_state),
) {
  element.define(field: by.css("input#age"))
  |> element.perform_action(driver, action)
}

pub fn country_dropdown(
  driver: WebDriver(state),
  action: fn(_) -> WebDriver(new_state),
) {
  select_element.define(field: by.css("select#country"))
  |> select_element.perform_action(driver, action)
}

pub fn comments_field(
  driver: WebDriver(state),
  action: fn(_) -> WebDriver(new_state),
) {
  element.define(field: by.css("textarea#comments"))
  |> element.perform_action(driver, action)
}

pub fn submit_form_button(
  driver: WebDriver(state),
  action: fn(_) -> WebDriver(new_state),
) {
  element.define(field: by.css("button#submitBtn"))
  |> element.perform_action(driver, action)
}

pub fn change_color_button(
  driver: WebDriver(state),
  action: fn(_) -> WebDriver(new_state),
) {
  element.define(field: by.css("button#changeColorBtn"))
  |> element.perform_action(driver, action)
}

pub fn clear_form_button(
  driver: WebDriver(state),
  action: fn(_) -> WebDriver(new_state),
) {
  element.define(field: by.css("button#clearBtn"))
  |> element.perform_action(driver, action)
}

pub fn data_table(
  driver: WebDriver(state),
  on_element: NodeTable,
  action: fn(_) -> WebDriver(new_state),
) {
  table_element.define(
    table: by.xpath("//table"),
    table_row: by.css("tr"),
    table_cell: by.xpath("//td"),
    table_width: 3,
  )
  |> table_element.perform_action(driver, on_element, action)
}

pub fn test_list(
  driver: WebDriver(state),
  on_element: NodeList,
  action: fn(_) -> WebDriver(new_state),
) {
  list_element.define(
    list: by.xpath("//ul[@id='testList']"),
    list_item: by.xpath("//li"),
  )
  |> list_element.perform_action(driver, on_element, action)
}

pub fn test_link(
  driver: WebDriver(state),
  action: fn(_) -> WebDriver(new_state),
) {
  element.define(field: by.css("a#externalLink"))
  |> element.perform_action(driver, action)
}

pub fn disabled_link(
  driver: WebDriver(state),
  action: fn(_) -> WebDriver(new_state),
) {
  element.define(field: by.css("a#disabledLink"))
  |> element.perform_action(driver, action)
}
