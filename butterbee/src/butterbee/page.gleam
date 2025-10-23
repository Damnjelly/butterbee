////
//// The page module contains functions to work with the current page
////

import butterbee/commands/browsing_context
import butterbee/internal/error
import butterbee/webdriver.{type WebDriver}
import butterbidi/browsing_context/commands/get_tree
import gleam/list
import gleam/result

///
/// Returns the url of the current page
/// 
/// # Example
///
/// This example returns "https://gleam.run/", the url of the current page:
///
/// ```gleam
/// let example = webdriver.new()
///   |> webdriver.goto("https://gleam.run/")
///   |> page.url()
/// ```
///
pub fn url(driver: WebDriver(state)) -> WebDriver(String) {
  case browsing_context.get_tree(driver, get_tree.default) {
    Error(error) -> Error(error)
    Ok(get_tree_result) -> {
      list.first(get_tree_result.contexts.list)
      |> result.map_error(fn(_) { error.NoInfoFound })
      |> result.map(fn(context) { context.url })
    }
  }
  |> webdriver.map_state(driver)
}
