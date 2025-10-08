////
//// The page module contains functions to work with the current page
////

import butterbee/commands/browsing_context
import butterbee/internal/lib
import butterbee/webdriver.{type WebDriver}
import butterbidi/browsing_context/commands/get_tree

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
pub fn url(driver: WebDriver) -> #(WebDriver, String) {
  let assert Ok(get_tree_result) =
    browsing_context.get_tree(driver.socket, get_tree.default())

  let assert Ok(info) = lib.single_element(get_tree_result.contexts.list)
    as "Found more than one, or zero, browsing contexts"

  #(driver, info.url)
}
