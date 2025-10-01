////
//// # [Browser commands](https://w3c.github.io/webdriver-bidi/#module-browser-commands) 
////

import butterbee/bidi/browser/definition as browser_definition
import butterbee/bidi/definition
import butterbee/internal/id
import butterbee/internal/socket

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
