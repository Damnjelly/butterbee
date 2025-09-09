import simplifile

pub type Error {
  CreatePortDirError(simplifile.FileError)
  CreateProfileDirError(simplifile.FileError)
  FileError(simplifile.FileError)
  ReadPortDirError(simplifile.FileError)
  RunnerError(Error)
}
