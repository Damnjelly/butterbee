////
//// # [Browser commands](https://w3c.github.io/webdriver-bidi/#module-browser-commands) 
////
//// The browser commands module contains commands found in the browser section of the
//// webdriver bidi protocol. Butterbee usese these internally to create the high level
//// API. But you can use these commands directly if you want something specific.
////
//// These commands usually expect parameter defined in the [butterbdi project](https://hexdocs.pm/butterbidi/index.html).
////

import butterbee/internal/id
import butterbee/internal/socket
import butterbidi/browser/definition as browser_definition
import butterbidi/definition

/// 
/// # [browser.close](https://w3c.github.io/webdriver-bidi/#command-browser-close)
/// 
/// Closes the current browser.
/// 
pub fn close(socket: socket.WebDriverSocket) -> Nil {
  let command = definition.BrowserCommand(browser_definition.Close)
  let request =
    definition.command_to_json(
      definition.Command(id.from_unix(), command, [
        #("params", definition.empty_params_to_json(definition.EmptyParams([]))),
      ]),
    )

  let _ = socket.send_request(socket, request, command)

  Nil
}
