//// Define elements for page module using this module.
////
//// Example:
////
//// ```gleam
//// import butterbee/page_module/select_element
////
//// pub fn pokemon_dropdown(
////   driver: WebDriver(state),
////   action: fn(_) -> WebDriver(new_state),
//// ) {
////   select_element.define(field: by.css("select#pokemon"))
////   |> select_element.perform_action(driver, action)
//// }
////
//// // Select an option by its visible text
//// driver
//// |> form_page.pokemon_dropdown(select_element.option("Charmander"))
////
//// // Get the currently selected option's text
//// driver
//// |> form_page.pokemon_dropdown(select_element.selected_text())
//// ```
////
//// For a more complete example, see the [`page module`](https://hexdocs.pm/butterbee/page-modules) guide.

import butterbee/get
import butterbee/internal/function
import butterbee/webdriver.{type WebDriver}
import butterbidi/browsing_context/types/locator.{type Locator}
import butterbidi/script/types/local_value
import butterbidi/script/types/remote_value

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
  // Sets the value of a <select> element based on the innerText of one of its options.
  // @param {string} innerTextValue – The exact innerText of the option that should become selected.
  // @this {HTMLSelectElement} – The select element whose value will be updated.
  let function =
    "function setSelectByInnerText(innerTextValue) {
      if (!this || this.tagName !== 'SELECT') {
        throw new TypeError('Function must be called on a <select> element');
      }

      for (let i = 0; i < this.options.length; i++) {
        if (this.options[i].innerText === innerTextValue) {
          this.selectedIndex = i;
          return; // Stop once the match is found
        }
      }

      throw new Error(`No option with innerText \"${innerTextValue}\" found`);
    }"

  fn(driver: WebDriver(remote_value.NodeRemoteValue)) {
    let _ =
      driver
      |> webdriver.with_state({
        case driver.state {
          Error(error) -> Error(error)
          Ok(node) -> Ok(local_value.node(node))
        }
      })
      |> function.on_value([local_value.string(option)], function)
    driver
  }
}

pub fn selected_text() -> fn(WebDriver(remote_value.NodeRemoteValue)) ->
  WebDriver(String) {
  fn(driver: WebDriver(remote_value.NodeRemoteValue)) -> WebDriver(String) {
    driver
    |> function.on_node(
      [],
      "function() { return this.options[this.selectedIndex].text; }",
    )
    |> function.result_to_string
    |> webdriver.map_state(driver)
  }
}
