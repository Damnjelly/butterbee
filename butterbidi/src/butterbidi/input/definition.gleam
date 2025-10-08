import gleam/json.{type Json}

pub type InputCommand {
  PerformActions
}

pub fn input_command_to_json(command: InputCommand) -> Json {
  json.string(input_command_to_string(command))
}

pub fn input_command_to_string(command: InputCommand) -> String {
  case command {
    PerformActions -> "input.performActions"
  }
}
