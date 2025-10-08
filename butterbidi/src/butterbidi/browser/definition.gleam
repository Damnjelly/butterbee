import gleam/json.{type Json}

pub type BrowserCommand {
  Close
}

pub fn browser_command_to_json(command: BrowserCommand) -> Json {
  json.string(browser_command_to_string(command))
}

pub fn browser_command_to_string(command: BrowserCommand) -> String {
  case command {
    Close -> "browser.close"
  }
}
