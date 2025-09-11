import butterbee/driver
import logging
import simplifile

pub fn init() {
  logging.log(logging.Debug, "Initializing butterbee")

  logging.log(logging.Debug, "Deleteing data_dir")
  let _ = simplifile.delete("/tmp/butterbee")

  Nil
}

pub fn main() {
  logging.configure()
  logging.set_level(logging.Debug)
  driver.new()
}
