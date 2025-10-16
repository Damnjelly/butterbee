import simplifile

pub type PortError {
  SocketError(String)
  BindError(String)
}

pub type ButterbeeError {
  CreateUserPrefsError(simplifile.FileError)
  CreatePortDirError(simplifile.FileError)
  CreateProfileDirError(simplifile.FileError)
  FileError(simplifile.FileError)
  ReadPortDirError(simplifile.FileError)
  RunnerError
  PortError(PortError)
}
