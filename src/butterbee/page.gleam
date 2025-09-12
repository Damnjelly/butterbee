import butterbee/bidi/browsing_context/commands/get_tree
import butterbee/commands/browsing_context
import butterbee/internal/lib
import butterbee/webdriver.{type WebDriver}

pub fn url(driver: WebDriver) -> #(WebDriver, String) {
  let assert Ok(get_tree_result) =
    browsing_context.get_tree(driver.socket, get_tree.default())

  let assert Ok(info) = lib.single_element(get_tree_result.contexts.list)
    as "Found more than one, or zero, browsing contexts"

  #(driver, info.url)
}
