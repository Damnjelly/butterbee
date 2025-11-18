import argv
import butterbee
import butterbee/config.{Chromium, Firefox}
import butterbee/internal/log
import gleeunit
import palabres/level
import pprint.{BitArraysAsString, Config, NoLabels, Styled}

pub const timeout = 30.0

pub const browsers = [Chromium, Firefox]

fn load_arguments() {
  case argv.load().arguments {
    ["--debug"] -> {
      log.configure(level.Debug)
    }
    _ -> log.configure(level.Warning)
  }
}

pub fn main() {
  load_arguments()
  butterbee.init()
  gleeunit.main()
}

pub type Timeout {
  Timeout(Float, fn() -> Nil)
}

pub fn pretty_print(value: a) -> String {
  value
  |> pprint.with_config(Config(
    style_mode: Styled,
    bit_array_mode: BitArraysAsString,
    label_mode: NoLabels,
  ))
}
