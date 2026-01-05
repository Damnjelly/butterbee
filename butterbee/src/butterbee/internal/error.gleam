import butterbidi/definition
import gleam/json
import simplifile
import stratus

pub type WebSocketError {
  CouldNotSendRequest(stratus.SocketReason)
  CouldNotStart(stratus.SocketReason)
  CouldNotInit(stratus.InitializationError)
}

pub type PortError {
  SocketError(String)
  BindError(String)
}

pub type ButterbeeError {
  BidiError(definition.ErrorResponse)
  BrowserDoesNotHaveCmd
  BrowserDoesNotHaveProfileDir
  BrowserDoesNotHaveRequest
  CouldNotConvertToLocalValue
  CouldNotDeleteProfileDir(simplifile.FileError)
  CouldNotGetIdFromSendCommand(json.DecodeError)
  CouldNotGetIdFromSocketResponse(json.DecodeError)
  CouldNotGetSubjectFromSocketResponse(json.DecodeError)
  CouldNotParseResponse(json.DecodeError)
  CouldNotParseSocketResponse(json.DecodeError)
  CouldNotParseUrl(url: String)
  CouldNotStartSession
  WebSocketError(WebSocketError)
  CreatePortDirError(simplifile.FileError)
  CreateProfileDirError(simplifile.FileError)
  CreateUserPrefsError(simplifile.FileError)
  DriverDoesNotHaveContext
  DriverDoesNotHaveSocket
  DriverDoesNotHaveState
  FileError(simplifile.FileError)
  MoreThanOneNodeFound
  NoBrowsingContexts
  NoInfoFound
  NoNodeFound
  NodeDoesNotHaveSharedId
  NodeTextIsNull
  NodeIsNotALocalValue
  NodeNotFound
  PortError(PortError)
  ReadPortDirError(simplifile.FileError)
  ResponseDoesNotHaveCorrespondingRequestId(id: Int)
  RunnerError
  SelectDoesNotHaveValue(String)
  UnexpectedBrowsingContextResultType
  UnexpectedGetTreeResultType
  UnexpectedNewResultType
  UnexpectedScriptResultType
  UnexpectedSessionResultType
  UnexpectedStatusResultType
  ToBoolError(String)
}
