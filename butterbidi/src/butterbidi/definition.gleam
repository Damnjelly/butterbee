import butterbidi/browser/definition as browser
import butterbidi/browsing_context/definition as browsing_context
import butterbidi/errors
import butterbidi/input/definition as input
import butterbidi/script/definition as script
import butterbidi/session/definition as session
import gleam/dict.{type Dict}
import gleam/dynamic.{type Dynamic}
import gleam/dynamic/decode.{type Decoder}
import gleam/json.{type Json}
import gleam/list
import gleam/option.{type Option}

pub type Command {
  Command(id: Int, command_data: CommandData, extensible: List(#(String, Json)))
}

pub fn command_to_json(command: Command) -> Json {
  let Command(id:, command_data:, extensible:) = command
  json.object(
    [#("id", json.int(id)), #("method", command_data_to_json(command_data))]
    |> list.append(extensible),
  )
}

pub type CommandData {
  SessionCommand(session_command: session.SessionCommand)
  BrowserCommand(browser_command: browser.BrowserCommand)
  BrowsingContextCommand(
    browsing_context_command: browsing_context.BrowsingContextCommand,
  )
  ScriptCommand(script_command: script.ScriptCommand)
  InputCommand(input_command: input.InputCommand)
}

pub fn command_data_to_json(command_data: CommandData) -> Json {
  case command_data {
    SessionCommand(session_command) ->
      session.session_command_to_json(session_command)
    BrowserCommand(browser_command) ->
      browser.browser_command_to_json(browser_command)
    BrowsingContextCommand(browsing_context_command) ->
      browsing_context.browsing_context_command_to_json(
        browsing_context_command,
      )
    ScriptCommand(script_command) ->
      script.script_command_to_json(script_command)
    InputCommand(input_command) -> input.input_command_to_json(input_command)
  }
}

pub type EmptyParams {
  EmptyParams(extensible: List(#(String, Json)))
}

pub fn empty_params_to_json(empty_params: EmptyParams) -> Json {
  let EmptyParams(extensible:) = empty_params
  json.object(extensible)
}

pub type Message {
  Success
  Error
  //TODO: Event
}

pub fn message_decoder() -> Decoder(Message) {
  use message_type <- decode.field("type", decode.string)
  case message_type {
    "success" -> decode.success(Success)
    "error" -> decode.success(Error)
    _ -> decode.failure(Error, "Message")
  }
}

pub type CommandResponse {
  CommandResponse(
    command_type: String,
    id: Int,
    result: ResultData,
    extensible: List(#(String, Json)),
  )
}

pub fn command_response_decoder(
  command: CommandData,
) -> Decoder(CommandResponse) {
  use command_type <- decode.field("type", decode.string)
  use id <- decode.field("id", decode.int)
  use result <- decode.field("result", result_data_decoder(command))
  decode.success(CommandResponse(command_type:, id:, result:, extensible: []))
}

pub fn extensible_command_response_decoder() -> Decoder(Dict(String, Dynamic)) {
  use capabilities <- decode.then(decode.dict(decode.string, decode.dynamic))

  let extensible =
    dict.to_list(capabilities)
    |> list.filter(fn(entry) {
      let #(key, _value) = entry
      case key {
        "type" | "id" | "result" -> False
        _ -> True
      }
    })
    |> dict.from_list()

  decode.success(extensible)
}

pub type ResultData {
  SessionResult(session_result: session.SessionResult)
  BrowsingContextResult(
    browsing_context_result: browsing_context.BrowsingContextResult,
  )
  ScriptResult(script_result: script.ScriptResult)
  EmptyResult
}

fn result_data_decoder(command: CommandData) -> Decoder(ResultData) {
  case command {
    SessionCommand(session_command) -> {
      use session_result <- decode.then(session.session_result_decoder(
        session_command,
      ))
      decode.success(SessionResult(session_result:))
    }
    BrowserCommand(_) -> decode.success(EmptyResult)
    BrowsingContextCommand(browsing_context_command) -> {
      use browsing_context_result <- decode.then(
        browsing_context.browsing_context_result_decoder(
          browsing_context_command,
        ),
      )
      decode.success(BrowsingContextResult(browsing_context_result))
    }
    ScriptCommand(script_command) -> {
      use script_result <- decode.then(script.script_result_decoder(
        script_command,
      ))
      decode.success(ScriptResult(script_result))
    }
    InputCommand(_) -> decode.success(EmptyResult)
  }
}

pub type ErrorResponse {
  ErrorResponse(
    error_type: String,
    id: Int,
    error: errors.ErrorCode,
    message: String,
    stacktrace: Option(String),
    extensible: List(#(String, Json)),
  )
}

pub fn error_response_decoder() -> Decoder(ErrorResponse) {
  use error_type <- decode.field("type", decode.string)
  use id <- decode.field("id", decode.int)
  use error <- decode.field("error", errors.error_code_decoder())
  use message <- decode.field("message", decode.string)
  use stacktrace <- decode.field("stacktrace", decode.optional(decode.string))
  decode.success(
    ErrorResponse(
      error_type:,
      id:,
      error:,
      message:,
      stacktrace:,
      extensible: [],
    ),
  )
}

pub fn extensible_error_response_decoder() -> Decoder(Dict(String, Dynamic)) {
  use capabilities <- decode.then(decode.dict(decode.string, decode.dynamic))

  let extensible =
    dict.to_list(capabilities)
    |> list.filter(fn(entry) {
      let #(key, _value) = entry
      case key {
        "type" | "id" | "error" | "message" | "stacktrace" -> False
        _ -> True
      }
    })
    |> dict.from_list()

  decode.success(extensible)
}
