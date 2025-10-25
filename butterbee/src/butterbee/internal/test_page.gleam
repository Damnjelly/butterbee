import butterbee/by
import butterbee/driver
import butterbee/page_module/node_element
import butterbee/page_module/node_list.{type NodeList}
import butterbee/page_module/node_select
import butterbee/page_module/node_table.{type NodeTable}
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
  node_element.define(field: by.xpath("//body"))
  |> node_element.perform_action(driver, action)
}

pub fn username_field(
  driver: WebDriver(state),
  action: fn(_) -> WebDriver(new_state),
) {
  node_element.define(field: by.css("input#username"))
  |> node_element.perform_action(driver, action)
}

pub fn email_field(
  driver: WebDriver(state),
  action: fn(_) -> WebDriver(new_state),
) {
  node_element.define(field: by.css("input#email"))
  |> node_element.perform_action(driver, action)
}

pub fn age_field(
  driver: WebDriver(state),
  action: fn(_) -> WebDriver(new_state),
) {
  node_element.define(field: by.css("input#age"))
  |> node_element.perform_action(driver, action)
}

pub fn country_dropdown(
  driver: WebDriver(state),
  action: fn(_) -> WebDriver(new_state),
) {
  node_select.define(field: by.css("select#country"))
  |> node_select.perform_action(driver, action)
}

pub fn comments_field(
  driver: WebDriver(state),
  action: fn(_) -> WebDriver(new_state),
) {
  node_element.define(field: by.css("textarea#comments"))
  |> node_element.perform_action(driver, action)
}

pub fn submit_form_button(
  driver: WebDriver(state),
  action: fn(_) -> WebDriver(new_state),
) {
  node_element.define(field: by.css("button#submitBtn"))
  |> node_element.perform_action(driver, action)
}

pub fn change_color_button(
  driver: WebDriver(state),
  action: fn(_) -> WebDriver(new_state),
) {
  node_element.define(field: by.css("button#changeColorBtn"))
  |> node_element.perform_action(driver, action)
}

pub fn clear_form_button(
  driver: WebDriver(state),
  action: fn(_) -> WebDriver(new_state),
) {
  node_element.define(field: by.css("button#clearBtn"))
  |> node_element.perform_action(driver, action)
}

pub fn data_table(
  driver: WebDriver(state),
  on_element: NodeTable,
  action: fn(_) -> WebDriver(new_state),
) {
  node_table.define(
    table: by.xpath("//table"),
    table_row: by.css("tr"),
    table_cell: by.xpath("//td"),
    table_width: 3,
  )
  |> node_table.perform_action(driver, on_element, action)
}

pub fn test_list(
  driver: WebDriver(state),
  on_element: NodeList,
  action: fn(_) -> WebDriver(new_state),
) {
  node_list.define(
    list: by.xpath("//ul[@id='testList']"),
    list_item: by.xpath("//li"),
  )
  |> node_list.perform_action(driver, on_element, action)
}

pub fn test_link(
  driver: WebDriver(state),
  action: fn(_) -> WebDriver(new_state),
) {
  node_element.define(field: by.css("a#externalLink"))
  |> node_element.perform_action(driver, action)
}

pub fn disabled_link(
  driver: WebDriver(state),
  action: fn(_) -> WebDriver(new_state),
) {
  node_element.define(field: by.css("a#disabledLink"))
  |> node_element.perform_action(driver, action)
}
