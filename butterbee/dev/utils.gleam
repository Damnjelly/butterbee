import argv
import butterbee/internal/log
import palabres/level
import pprint.{BitArraysAsString, Config, NoLabels, Styled}

pub fn load_arguments() {
  case argv.load().arguments {
    ["--debug"] -> {
      log.configure(level.Debug)
    }
    _ -> log.configure(level.Warning)
  }
}

pub fn pretty_print(value: a) -> String {
  value
  |> pprint.with_config(Config(
    style_mode: Styled,
    bit_array_mode: BitArraysAsString,
    label_mode: NoLabels,
  ))
}
