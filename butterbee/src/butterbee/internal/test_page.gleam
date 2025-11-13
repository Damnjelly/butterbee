import butterbee
import butterbee/by
import butterbee/element.{type NodeList, type NodeTable}
import butterbee/webdriver.{type WebDriver}
import simplifile

pub fn goto(driver: WebDriver(state)) {
  let file_path = case simplifile.current_directory() {
    Ok(cwd) -> cwd <> "/assets/test_page.html"
    Error(_) -> panic as "Could not get current working directory"
  }
  butterbee.goto(driver, "file://" <> file_path)
}

pub fn body(driver: WebDriver(state), action: fn(_) -> WebDriver(new_state)) {
  element.define(field: by.xpath("//body"))
  |> element.perform(driver, action)
}

pub fn username_field(
  driver: WebDriver(state),
  action: fn(_) -> WebDriver(new_state),
) {
  element.define(field: by.css("input#username"))
  |> element.perform(driver, action)
}

pub fn email_field(
  driver: WebDriver(state),
  action: fn(_) -> WebDriver(new_state),
) {
  element.define(field: by.css("input#email"))
  |> element.perform(driver, action)
}

pub fn age_field(
  driver: WebDriver(state),
  action: fn(_) -> WebDriver(new_state),
) {
  element.define(field: by.css("input#age"))
  |> element.perform(driver, action)
}

pub fn country_dropdown(
  driver: WebDriver(state),
  action: fn(_) -> WebDriver(new_state),
) {
  element.define(field: by.css("select#country"))
  |> element.perform(driver, action)
}

pub fn comments_field(
  driver: WebDriver(state),
  action: fn(_) -> WebDriver(new_state),
) {
  element.define(field: by.css("textarea#comments"))
  |> element.perform(driver, action)
}

pub fn submit_form_button(
  driver: WebDriver(state),
  action: fn(_) -> WebDriver(new_state),
) {
  element.define(field: by.css("button#submitBtn"))
  |> element.perform(driver, action)
}

pub fn change_color_button(
  driver: WebDriver(state),
  action: fn(_) -> WebDriver(new_state),
) {
  element.define(field: by.css("button#changeColorBtn"))
  |> element.perform(driver, action)
}

pub fn clear_form_button(
  driver: WebDriver(state),
  action: fn(_) -> WebDriver(new_state),
) {
  element.define(field: by.css("button#clearBtn"))
  |> element.perform(driver, action)
}

pub fn data_table(
  driver: WebDriver(state),
  on_element: NodeTable,
  action: fn(_) -> WebDriver(new_state),
) {
  element.define_table(
    table: by.xpath("//table"),
    table_row: by.css("tr"),
    table_cell: by.xpath("//td"),
    table_width: 3,
  )
  |> element.perform_on_table(driver, on_element, action)
}

pub fn test_list(
  driver: WebDriver(state),
  on_element: NodeList,
  action: fn(_) -> WebDriver(new_state),
) {
  element.define_list(
    list: by.xpath("//ul[@id='testList']"),
    list_item: by.xpath("//li"),
  )
  |> element.perform_on_list(driver, on_element, action)
}

pub fn test_link(
  driver: WebDriver(state),
  action: fn(_) -> WebDriver(new_state),
) {
  element.define(field: by.css("a#externalLink"))
  |> element.perform(driver, action)
}

pub fn disabled_link(
  driver: WebDriver(state),
  action: fn(_) -> WebDriver(new_state),
) {
  element.define(field: by.css("a#disabledLink"))
  |> element.perform(driver, action)
}
