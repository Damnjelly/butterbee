import logging
import simplifile

pub fn init() {
  logging.log(logging.Debug, "Initializing butterbee")

  logging.log(logging.Debug, "Deleteing data_dir")
  let _ = simplifile.delete("/tmp/butterbee")

  Nil
}
