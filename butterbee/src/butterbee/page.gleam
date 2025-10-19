////
//// The page module contains functions to work with the current page
////

import butterbee/commands/browsing_context
import butterbee/webdriver.{type WebDriver}
import butterbidi/browsing_context/commands/get_tree
import butterlib/log
import gleam/list
import gleam/string

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
    Ok(get_tree_result) -> {
      let err =
        "Could not get context info: " <> string.inspect(get_tree_result)
      let assert Ok(context) = list.first(get_tree_result.contexts.list) as err

      Ok(context.url)
    }
    Error(error) ->
      log.error_and_continue(
        "Could not get tree, error: " <> string.inspect(error),
        Error(error),
      )
  }
  |> webdriver.map_state(driver)
}
