import birdie
import butterbee/by
import butterbee/config
import butterbee/config/browser.{Firefox}
import butterbee/driver
import butterbee/get
import butterbee/internal/error.{type ButterbeeError}
import butterbee/internal/function
import butterbee/webdriver
import butterbee_test.{pretty_print, timeout}
import butterbidi/script/types/evaluate_result.{
  type EvaluateResult, EvaluateResultSuccess, SuccessResult,
}
import butterbidi/script/types/local_value.{type LocalValue}
import butterbidi/script/types/remote_value.{NodeRemote, NodeRemoteValue}
import gleam/option.{None, Some}
import gleam/result
import qcheck_gleeunit_utils/test_spec
import youid/uuid

pub fn evaluate_result_error_test_() {
  use <- test_spec.make_with_timeout(timeout)
  "function test_exception() { throw new Error('Test exception'); }"
  |> call_with_function([])
  |> filter_uuid_from_remote_value
  |> pretty_print
  |> birdie.snap(
    title: "When javascript throws,
  call_function should return an exception value",
  )
}

pub fn evaluate_result_node_value_test_() {
  use <- test_spec.make_with_timeout(timeout)
  "function test_node_value() { return this; }"
  |> call_with_function([])
  |> filter_uuid_from_remote_value
  |> pretty_print
  |> birdie.snap(
    title: "When javascript returns a node value,
  call_function should return a node remote value",
  )
}

pub fn evaluate_result_undefined_test_() {
  use <- test_spec.make_with_timeout(timeout)
  "function test_undefined() { return undefined; }"
  |> call_with_function([])
  |> pretty_print
  |> birdie.snap(
    title: "When javascript returns undefined,
  call_function should return an Undefined primitive value",
  )
}

pub fn evaluate_result_null_test_() {
  use <- test_spec.make_with_timeout(timeout)
  "function test_null() { return null; }"
  |> call_with_function([])
  |> pretty_print
  |> birdie.snap(
    title: "When javascript returns null,
  call_function should return a Null primitive value",
  )
}

pub fn evaluate_result_string_test_() {
  use <- test_spec.make_with_timeout(timeout)
  "function test_string() { return 'Hello World'; }"
  |> call_with_function([])
  |> pretty_print
  |> birdie.snap(
    title: "When javascript returns a string,
  call_function should return a String primitive value",
  )
}

pub fn evaluate_result_empty_string_test_() {
  use <- test_spec.make_with_timeout(timeout)
  "function test_empty_string() { return ''; }"
  |> call_with_function([])
  |> pretty_print
  |> birdie.snap(
    title: "When javascript returns an empty string,
  call_function should return an empty String primitive value",
  )
}

pub fn evaluate_result_integer_test_() {
  use <- test_spec.make_with_timeout(timeout)
  "function test_integer() { return 42; }"
  |> call_with_function([])
  |> pretty_print
  |> birdie.snap(
    title: "When javascript returns an integer,
  call_function should return an Int Number primitive value",
  )
}

pub fn evaluate_result_float_test_() {
  use <- test_spec.make_with_timeout(timeout)
  "function test_float() { return 3.14159; }"
  |> call_with_function([])
  |> pretty_print
  |> birdie.snap(
    title: "When javascript returns a float,
  call_function should return a Float Number primitive value",
  )
}

pub fn evaluate_result_negative_zero_test_() {
  use <- test_spec.make_with_timeout(timeout)
  "function test_negative_zero() { return -0; }"
  |> call_with_function([])
  |> pretty_print
  |> birdie.snap(
    title: "When javascript returns negative zero,
  call_function should return a NegativeZero special Number primitive value",
  )
}

pub fn evaluate_result_infinity_test_() {
  use <- test_spec.make_with_timeout(timeout)
  "function test_infinity() { return Infinity; }"
  |> call_with_function([])
  |> pretty_print
  |> birdie.snap(
    title: "When javascript returns Infinity,
  call_function should return an Infinity special Number primitive value",
  )
}

pub fn evaluate_result_negative_infinity_test_() {
  use <- test_spec.make_with_timeout(timeout)
  "function test_negative_infinity() { return -Infinity; }"
  |> call_with_function([])
  |> pretty_print
  |> birdie.snap(
    title: "When javascript returns negative Infinity,
  call_function should return a NegativeInfinity special Number primitive value",
  )
}

pub fn evaluate_result_nan_test_() {
  use <- test_spec.make_with_timeout(timeout)
  "function test_nan() { return NaN; }"
  |> call_with_function([])
  |> pretty_print
  |> birdie.snap(
    title: "When javascript returns NaN,
  call_function should return a NaN special Number primitive value",
  )
}

pub fn evaluate_result_boolean_true_test_() {
  use <- test_spec.make_with_timeout(timeout)
  "function test_boolean_true() { return true; }"
  |> call_with_function([])
  |> pretty_print
  |> birdie.snap(
    title: "When javascript returns true,
  call_function should return a Boolean primitive value with true",
  )
}

pub fn evaluate_result_boolean_false_test_() {
  use <- test_spec.make_with_timeout(timeout)
  "function test_boolean_false() { return false; }"
  |> call_with_function([])
  |> pretty_print
  |> birdie.snap(
    title: "When javascript returns false,
  call_function should return a Boolean primitive value with false",
  )
}

pub fn evaluate_result_bigint_test_() {
  use <- test_spec.make_with_timeout(timeout)
  "function test_bigint() { return BigInt('9007199254740991'); }"
  |> call_with_function([])
  |> pretty_print
  |> birdie.snap(
    title: "When javascript returns a BigInt,
  call_function should return a BigInt primitive value",
  )
}

pub fn evaluate_result_bigint_large_test_() {
  use <- test_spec.make_with_timeout(timeout)
  "function test_bigint_large() { return BigInt('123456789012345678901234567890'); }"
  |> call_with_function([])
  |> pretty_print
  |> birdie.snap(
    title: "When javascript returns a large BigInt,
  call_function should return a BigInt primitive value",
  )
}

pub fn evaluate_result_array_test_() {
  use <- test_spec.make_with_timeout(timeout)
  "function test_array() { return [1, 2, 3]; }"
  |> call_with_function([])
  |> pretty_print
  |> birdie.snap(
    title: "When javascript returns an array,
  call_function should return an array primitive value",
  )
}

pub fn int_parameter_test_() {
  use <- test_spec.make_with_timeout(timeout)
  "function test_int_parameter(a) { return a; }"
  |> call_with_function([local_value.int(42)])
  |> pretty_print
  |> birdie.snap(
    title: "When javascript returns an int parameter,
  call_function should return an int primitive value",
  )
}

pub fn float_parameter_test_() {
  use <- test_spec.make_with_timeout(timeout)
  "function test_float_parameter(a) { return a; }"
  |> call_with_function([local_value.float(42.5)])
  |> pretty_print
  |> birdie.snap(
    title: "When javascript returns a float parameter,
  call_function should return a float primitive value",
  )
}

pub fn string_parameter_test_() {
  use <- test_spec.make_with_timeout(timeout)
  "function test_string_parameter(a) { return a; }"
  |> call_with_function([local_value.string("Hello World")])
  |> pretty_print
  |> birdie.snap(
    title: "When javascript returns a string parameter,
  call_function should return a string primitive value",
  )
}

pub fn boolean_parameter_test_() {
  use <- test_spec.make_with_timeout(timeout)
  "function test_boolean_parameter(a) { return a; }"
  |> call_with_function([local_value.boolean(True)])
  |> pretty_print
  |> birdie.snap(
    title: "When javascript returns a boolean parameter,
  call_function should return a boolean primitive value",
  )
}

fn filter_uuid_from_remote_value(
  result: Result(EvaluateResult, ButterbeeError),
) -> Result(EvaluateResult, ButterbeeError) {
  result.map(result, fn(evaluate_result) {
    case evaluate_result {
      SuccessResult(EvaluateResultSuccess(t, NodeRemote(node_remote_value))) -> {
        let NodeRemoteValue(a, id, c, d, e) = node_remote_value
        let id = case id {
          None -> None
          Some(_) -> Some(uuid.nil)
        }
        SuccessResult(EvaluateResultSuccess(
          t,
          NodeRemote(NodeRemoteValue(a, id, c, d, e)),
        ))
      }
      r -> r
    }
  })
}

fn call_with_function(
  function: String,
  arguments: List(LocalValue),
) -> Result(EvaluateResult, ButterbeeError) {
  let browser_config =
    browser.default_configuration(browser.Firefox)
    |> browser.with_extra_flags(["-headless"])

  let config =
    config.default
    |> config.with_browser_config(browser.Firefox, browser_config)

  let driver = driver.new_with_config(Firefox, config)

  driver
  |> get.node(by.xpath("/html"))
  |> function.on_node(arguments, function)
  |> webdriver.map_state(driver)
  |> driver.close()
}
