import butterbee
import butterbee/config.{Chromium, Firefox}
import gleeunit
import utils

pub const timeout = 30.0

pub const browsers = [Chromium, Firefox]

pub type Timeout {
  Timeout(Float, fn() -> Nil)
}

pub fn main() {
  utils.load_arguments()
  butterbee.init()
  gleeunit.main()
}
