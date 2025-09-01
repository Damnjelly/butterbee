import butterbee/bidi/session/commands/new
import gleam/dynamic/decode.{type Decoder}
import gleam/json.{type Json}

pub type SessionCommand {
  New
  End
}

pub fn session_command_to_json(command: SessionCommand) -> Json {
  json.string(session_command_to_string(command))
}

pub fn session_command_to_string(command: SessionCommand) -> String {
  case command {
    New -> "session.new"
    End -> "session.end"
  }
}

pub type SessionResult {
  NewResult(new_result: new.NewResult)
  EmptyResult
}

pub fn session_result_decoder(command: SessionCommand) -> Decoder(SessionResult) {
  case command {
    New -> {
      use new_result <- decode.then(new.new_result_decoder())
      decode.success(NewResult(new_result: new_result))
    }
    End -> decode.success(EmptyResult)
  }
}
