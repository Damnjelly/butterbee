import birdie
import butterbee/config
import butterbee_test.{pretty_print, timeout}

pub fn driver_max_filled_test_() {
  use <- butterbee_test.Timeout(timeout)
  "
    [tools.butterbee.driver]
    max_wait_time = 10000
    request_timeout = 10000
    data_dir = '/another/dir'
  "
  |> config.parse_config_string
  |> pretty_print
  |> birdie.snap(title: "driver config maximally filled edits all fields")
}

pub fn driver_only_max_time_filled_test_() {
  use <- butterbee_test.Timeout(timeout)
  "
    [tools.butterbee.driver]
    max_wait_time = 33333
  "
  |> config.parse_config_string
  |> pretty_print
  |> birdie.snap(
    title: "driver config with only max wait time fills other fields with default values",
  )
}

pub fn driver_only_request_timeout_filled_test_() {
  use <- butterbee_test.Timeout(timeout)
  "
    [tools.butterbee.driver]
    request_timeout = 31415
  "
  |> config.parse_config_string
  |> pretty_print
  |> birdie.snap(
    title: "driver config with only request timeout fills other fields with default values",
  )
}

pub fn driver_only_data_dir_filled_test_() {
  use <- butterbee_test.Timeout(timeout)
  "
    [tools.butterbee.driver]
    data_dir = '/another/another/dir'
  "
  |> config.parse_config_string
  |> pretty_print
  |> birdie.snap(
    title: "driver config with only data dir fills other fields with default values",
  )
}

pub fn driver_min_filled_test_() {
  use <- butterbee_test.Timeout(timeout)
  "
    [tools.butterbee.driver]
  "
  |> config.parse_config_string
  |> pretty_print
  |> birdie.snap(title: "empty driver config, is filled with default values")
}

pub fn firefox_max_filled_test_() {
  use <- butterbee_test.Timeout(timeout)
  "
    [tools.butterbee.browser.firefox]
    cmd = '/path/to/firefox'
    flags = ['-headless']
    host = 'localhost'
  "
  |> config.parse_config_string
  |> pretty_print
  |> birdie.snap(title: "firefox config maximally filled edits all fields")
}

pub fn firefox_only_cmd_filled_test_() {
  use <- butterbee_test.Timeout(timeout)
  "
    [tools.butterbee.browser.firefox]
    cmd = '/path/to/firefox'
  "
  |> config.parse_config_string
  |> pretty_print
  |> birdie.snap(
    title: "firefox config with only cmd fills other fields with default values",
  )
}

pub fn firefox_only_flags_filled_test_() {
  use <- butterbee_test.Timeout(timeout)
  "
    [tools.butterbee.browser.firefox]
    flags = ['-headless']
  "
  |> config.parse_config_string
  |> pretty_print
  |> birdie.snap(
    title: "firefox config with only flags fills other fields with default values",
  )
}

pub fn firefox_only_host_filled_test_() {
  use <- butterbee_test.Timeout(timeout)
  "
    [tools.butterbee.browser.firefox]
    host = 'localhost'
  "
  |> config.parse_config_string
  |> pretty_print
  |> birdie.snap(
    title: "firefox config with only host fills other fields with default values",
  )
}

pub fn firefox_min_filled_test_() {
  use <- butterbee_test.Timeout(timeout)
  "
    [tools.butterbee.browser.firefox]
  "
  |> config.parse_config_string
  |> pretty_print
  |> birdie.snap(title: "empty firefox config, is filled with default values")
}

pub fn chromium_max_filled_test_() {
  use <- butterbee_test.Timeout(timeout)
  "
    [tools.butterbee.browser.chromium]
    cmd = '/path/to/chromium'
    flags = ['-headless']
    host = 'localhost'
  "
  |> config.parse_config_string
  |> pretty_print
  |> birdie.snap(title: "chromium config maximally filled edits all fields")
}

pub fn chromium_only_cmd_filled_test_() {
  use <- butterbee_test.Timeout(timeout)
  "
    [tools.butterbee.browser.chromium]
    cmd = '/path/to/chromium'
  "
  |> config.parse_config_string
  |> pretty_print
  |> birdie.snap(
    title: "chromium config with only cmd fills other fields with default values",
  )
}

pub fn chromium_only_flags_filled_test_() {
  use <- butterbee_test.Timeout(timeout)
  "
    [tools.butterbee.browser.chromium]
    flags = ['-headless']
  "
  |> config.parse_config_string
  |> pretty_print
  |> birdie.snap(
    title: "chromium config with only flags fills other fields with default values",
  )
}

pub fn chromium_only_host_filled_test_() {
  use <- butterbee_test.Timeout(timeout)
  "
    [tools.butterbee.browser.chromium]
    host = 'localhost'
  "
  |> config.parse_config_string
  |> pretty_print
  |> birdie.snap(
    title: "chromium config with only host fills other fields with default values",
  )
}

pub fn chromium_min_filled_test_() {
  use <- butterbee_test.Timeout(timeout)
  "
    [tools.butterbee.browser.chromium]
  "
  |> config.parse_config_string
  |> pretty_print
  |> birdie.snap(title: "empty chromium config, is filled with default values")
}

pub fn capabilities_w3c_values_test_() {
  use <- butterbee_test.Timeout(timeout)
  "
    [tools.butterbee.capabilities.always_match]
    acceptInsecureCerts = true
    browserName = 'chromium'
    browserVersion = 'latest'
    platformName = 'linux'
  "
  |> config.parse_config_string
  |> pretty_print
  |> birdie.snap(title: "capabilities config with w3c defined values")
}

pub fn always_match_primitives_test_() {
  use <- butterbee_test.Timeout(timeout)
  "
    [tools.butterbee.capabilities.always_match]
    bool = true
    int = 42
    float = 3.14159
    string = 'Hello World'
    table = { a = 1, b = 2, c = 3 }
    array = [ 1, 2, 3 ]
  "
  |> config.parse_config_string
  |> pretty_print
  |> birdie.snap(title: "always match can handle primitives")
}

pub fn first_match_primitives_test_() {
  use <- butterbee_test.Timeout(timeout)
  "
    [[tools.butterbee.capabilities.first_match]]
    bool = true
    int = 42
    float = 3.14159
    string = 'Hello World'
    table = { a = 1, b = 2, c = 3 }
    array = [ 1, 2, 3 ]
  "
  |> config.parse_config_string
  |> pretty_print
  |> birdie.snap(title: "first match can handle primitives")
}
