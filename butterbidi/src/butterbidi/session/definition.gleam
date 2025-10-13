import butterbidi/session/commands/new
import butterbidi/session/commands/status
import gleam/dynamic/decode.{type Decoder}
import gleam/json.{type Json}

pub type SessionCommand {
  Status
  New
  End
}

pub fn session_command_to_json(command: SessionCommand) -> Json {
  json.string(session_command_to_string(command))
}

pub fn session_command_to_string(command: SessionCommand) -> String {
  case command {
    Status -> "session.status"
    New -> "session.new"
    End -> "session.end"
  }
}

pub type SessionResult {
  StatusResult(status_result: status.StatusResult)
  NewResult(new_result: new.NewResult)
  EmptyResult
}

pub fn session_result_decoder(command: SessionCommand) -> Decoder(SessionResult) {
  case command {
    Status -> {
      use status_result <- decode.then(status.status_result_decoder())
      decode.success(StatusResult(status_result: status_result))
    }
    New -> {
      use new_result <- decode.then(new.new_result_decoder())
      decode.success(NewResult(new_result: new_result))
    }
    End -> decode.success(EmptyResult)
  }
}
