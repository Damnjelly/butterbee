////
//// ▗▄▄▄   ▄▄▄ ▄ ▄   ▄ ▗▞▀▚▖ ▄▄▄ 
//// ▐▌  █ █    ▄ █   █ ▐▛▀▀▘█    
//// ▐▌  █ █    █  ▀▄▀  ▝▚▄▄▖█    
//// ▐▙▄▄▀      █                 
////                                       
//// The driver module contains high-level commands for interacting with the webdriver server

import butterbee/internal/bidi/browsing_context.{type BrowsingContext}
import butterbee/internal/bidi/session
import butterbee/internal/socket.{type WebDriverSocket}
import gleam/list
import gleam/option.{None, Some}

pub type WebDriver {
  WebDriver(socket: WebDriverSocket, context: BrowsingContext)
}

/// Start a new webdriver session connect to the browse session
pub fn new() -> WebDriver {
  let session =
    session.new(session.CapabilitiesRequest(None, None, None, None, []))

  let tree = browsing_context.get_tree(session.0, None, None)

  let context = case list.length(tree) {
    1 -> {
      let assert Ok(context) = list.first(tree) as "Found no browsing contexts"
      context
    }
    _ -> panic as "Found more than one, or zero, browsing contexts"
  }
  WebDriver(session.0, context)
}

pub fn goto(driver: WebDriver, url: String) -> WebDriver {
  let new_driver =
    browsing_context.navigate(#(driver.socket, driver.context), url, None)
  WebDriver(new_driver.0, new_driver.1)
}
