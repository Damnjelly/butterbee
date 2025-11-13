//// ## [Browser commands](https://w3c.github.io/webdriver-bidi/#module-browser-commands) 
////
//// The browser commands module contains commands found in the browser section of the
//// webdriver bidi protocol. Butterbee usese these internally to create the high level
//// API. But you can use these commands directly if you want something specific.

import butterbee/internal/error
import butterbee/internal/id
import butterbee/internal/socket
import butterbee/webdriver
import butterbidi/browser/definition as browser_definition
import butterbidi/definition
import gleam/result

/// Closes the current browser.
/// 
/// [w3c](https://w3c.github.io/webdriver-bidi/#command-browser-close)
pub fn close(
  driver: webdriver.WebDriver(state),
) -> Result(definition.CommandResponse, error.ButterbeeError) {
  let command = definition.BrowserCommand(browser_definition.Close)
  let request =
    definition.command_to_json(
      definition.Command(id.from_unix(), command, [
        #("params", definition.empty_params_to_json(definition.EmptyParams([]))),
      ]),
    )

  use socket <- result.try({ webdriver.get_socket(driver) })

  socket.send_request(socket, request, command)
}
