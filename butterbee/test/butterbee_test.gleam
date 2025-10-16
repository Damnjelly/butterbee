import argv
import butterbee
import butterbee/by
import butterbee/config
import butterbee/config/browser
import butterbee/input
import butterbee/nodes
import butterbee/query
import butterbee/webdriver.{type WebDriver}
import butterlib/log
import gleam/dict
import gleam/option
import gleeunit
import logging
import pprint.{BitArraysAsString, Config, NoLabels, Styled}
import qcheck_gleeunit_utils/test_spec
import simplifile

pub const timeout = 30

pub fn main() {
  let _ = case argv.load().arguments {
    ["--debug"] -> {
      log.configure(logging.Debug)
    }
    _ -> log.configure(logging.Error)
  }
  butterbee.init()
  gleeunit.main()
}

pub fn minimal_example_test_() {
  use <- test_spec.make_with_timeout(timeout)
  let output =
    webdriver.new(browser.Firefox)
    |> webdriver.goto("https://gleam.run/")
    |> query.node(by.xpath(
      "//div[@class='hero']//a[@href='https://tour.gleam.run/']",
    ))
    |> input.click(input.LeftClick)
    |> query.node(by.css("pre.log"))
    |> nodes.inner_text()
    |> webdriver.close()
  assert output == "Hello, Joe!\n"
}

pub fn pretty_print(value: a) -> String {
  value
  |> pprint.with_config(Config(
    style_mode: Styled,
    bit_array_mode: BitArraysAsString,
    label_mode: NoLabels,
  ))
}

pub fn test_page(browser: browser.BrowserType) -> WebDriver {
  let assert Ok(config) = config.parse_config("gleam.toml")

  let file_path = case simplifile.current_directory() {
    Ok(cwd) -> cwd <> "/assets/test_page.html"
    Error(_) -> panic as "Could not get current working directory"
  }

  let browser_config =
    case config.browser_config {
      option.None -> browser.default()
      option.Some(browser_config) -> browser_config
    }
    |> dict.map_values(fn(_browser_type, browser_config) {
      browser_config
      |> browser.with_start_url(file_path)
    })

  let config =
    config
    |> config.with_browser_config(browser_config)

  webdriver.new_with_config(browser, config)
}
