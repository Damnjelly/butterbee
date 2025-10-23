import butterbidi/definition
import gleam/json
import simplifile
import stratus

pub type PortError {
  SocketError(String)
  BindError(String)
}

pub type ButterbeeError {
  BidiError(definition.ErrorResponse)
  BrowserDoesNotHaveRequest
  BrowserDoesNotHaveCmd
  BrowserDoesNotHaveProfileDir
  CouldNotParseUrl(url: String)
  CouldNotDeleteProfileDir(simplifile.FileError)
  CreatePortDirError(simplifile.FileError)
  CreateProfileDirError(simplifile.FileError)
  CreateUserPrefsError(simplifile.FileError)
  DriverDoesNotHaveConfig
  DriverDoesNotHaveContext
  DriverDoesNotHaveSocket
  DriverDoesNotHaveState
  FileError(simplifile.FileError)
  MoreThanOneNodeFound
  NoBrowsingContexts
  NoNodeFound
  NoInfoFound
  NodeDoesNotHaveSharedId
  NodeNotFound
  PortError(PortError)
  CouldNotStartSession
  CouldNotStartWebSocket(stratus.InitializationError)
  ReadPortDirError(simplifile.FileError)
  CouldNotParseResponse(json.DecodeError)
  CouldNotParseSocketResponse(json.DecodeError)
  CouldNotGetIdFromSocketResponse(json.DecodeError)
  CouldNotGetIdFromSendCommand(json.DecodeError)
  CouldNotSendWebSocketRequest(stratus.SocketReason)
  CouldNotGetSubjectFromSocketResponse(json.DecodeError)
  ResponseDoesNotHaveCorrespondingRequestId(id: Int)
  CouldNotStopWebSocket(stratus.SocketReason)
  RunnerError
  UnexpectedBrowsingContextResultType
  UnexpectedGetTreeResultType
  UnexpectedNewResultType
  UnexpectedScriptResultType
  UnexpectedSessionResultType
  UnexpectedStatusResultType
}
