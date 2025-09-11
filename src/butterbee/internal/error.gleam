import simplifile

pub type ButterbeeError {
  CreatePortDirError(simplifile.FileError)
  CreateProfileDirError(simplifile.FileError)
  FileError(simplifile.FileError)
  ReadPortDirError(simplifile.FileError)
  RunnerError
}
