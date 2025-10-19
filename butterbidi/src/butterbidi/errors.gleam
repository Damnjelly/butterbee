import gleam/dynamic/decode

pub type ErrorCode {
  InvalidArgument
  InvalidSelector
  InvalidSessionId
  InvalidWebExtension
  MoveTargetOutOfBounds
  NoSuchAlert
  NoSuchNetworkCollector
  NoSuchElement
  NoSuchFrame
  NoSuchHandle
  NoSuchHistoryEntry
  NoSuchIntercept
  NoSuchNetworkData
  NoSuchNode
  NoSuchScript
  NoSuchStoragePartition
  NoSuchUserContext
  NoSuchWebExtension
  SessionNotCreated
  UnableToCaptureScreen
  UnableToCloseBrowser
  UnableToSetCookie
  UnableToSetFileInput
  UnavailableNetworkData
  UnderspecifiedStoragePartition
  UnknownCommand
  UnknownError
  UnsupportedOperation
}

pub fn error_code_decoder() -> decode.Decoder(ErrorCode) {
  use variant <- decode.then(decode.string)
  case variant {
    "invalid argument" -> decode.success(InvalidArgument)
    "invalid selector" -> decode.success(InvalidSelector)
    "invalid session id" -> decode.success(InvalidSessionId)
    "invalid web extension" -> decode.success(InvalidWebExtension)
    "move target out of bounds" -> decode.success(MoveTargetOutOfBounds)
    "no such alert" -> decode.success(NoSuchAlert)
    "no such network collector" -> decode.success(NoSuchNetworkCollector)
    "no such element" -> decode.success(NoSuchElement)
    "no such frame" -> decode.success(NoSuchFrame)
    "no such handle" -> decode.success(NoSuchHandle)
    "no such history entry" -> decode.success(NoSuchHistoryEntry)
    "no such intercept" -> decode.success(NoSuchIntercept)
    "no such network data" -> decode.success(NoSuchNetworkData)
    "no such node" -> decode.success(NoSuchNode)
    "no such script" -> decode.success(NoSuchScript)
    "no such storage partition" -> decode.success(NoSuchStoragePartition)
    "no such user context" -> decode.success(NoSuchUserContext)
    "no such web extension" -> decode.success(NoSuchWebExtension)
    "session not created" -> decode.success(SessionNotCreated)
    "unable to capture screen" -> decode.success(UnableToCaptureScreen)
    "unable to close browser" -> decode.success(UnableToCloseBrowser)
    "unable to set cookie" -> decode.success(UnableToSetCookie)
    "unable to set file input" -> decode.success(UnableToSetFileInput)
    "unavailable network data" -> decode.success(UnavailableNetworkData)
    "underspecified storage partition" ->
      decode.success(UnderspecifiedStoragePartition)
    "unknown command" -> decode.success(UnknownCommand)
    "unknown error" -> decode.success(UnknownError)
    "unsupported operation" -> decode.success(UnsupportedOperation)
    _ -> decode.failure(UnknownError, "ErrorCode")
  }
}

pub fn error_code_to_string(error_code: ErrorCode) -> String {
  case error_code {
    InvalidArgument -> "invalid argument"
    InvalidSelector -> "invalid selector"
    InvalidSessionId -> "invalid session id"
    InvalidWebExtension -> "invalid web extension"
    MoveTargetOutOfBounds -> "move target out of bounds"
    NoSuchAlert -> "no such alert"
    NoSuchNetworkCollector -> "no such network collector"
    NoSuchElement -> "no such element"
    NoSuchFrame -> "no such frame"
    NoSuchHandle -> "no such handle"
    NoSuchHistoryEntry -> "no such history entry"
    NoSuchIntercept -> "no such intercept"
    NoSuchNetworkData -> "no such network data"
    NoSuchNode -> "no such node"
    NoSuchScript -> "no such script"
    NoSuchStoragePartition -> "no such storage partition"
    NoSuchUserContext -> "no such user context"
    NoSuchWebExtension -> "no such web extension"
    SessionNotCreated -> "session not created"
    UnableToCaptureScreen -> "unable to capture screen"
    UnableToCloseBrowser -> "unable to close browser"
    UnableToSetCookie -> "unable to set cookie"
    UnableToSetFileInput -> "unable to set file input"
    UnavailableNetworkData -> "unavailable network data"
    UnderspecifiedStoragePartition -> "underspecified storage partition"
    UnknownCommand -> "unknown command"
    UnknownError -> "unknown error"
    UnsupportedOperation -> "unsupported operation"
  }
}
