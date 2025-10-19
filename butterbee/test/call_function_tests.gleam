import birdie
import butterbee/by
import butterbee/config/browser.{Firefox}
import butterbee/driver
import butterbee/get
import butterbee/node
import butterbee/webdriver
import butterbee_test.{pretty_print, timeout}
import butterbidi/definition.{type ErrorResponse}
import butterbidi/script/types/evaluate_result.{
  type EvaluateResult, EvaluateResultSuccess, ExceptionResult, SuccessResult,
}
import butterbidi/script/types/remote_value.{NodeRemote, NodeRemoteValue}
import butterlib/log
import gleam/list
import gleam/option.{None, Some}
import gleam/result
import gleam/string
import qcheck_gleeunit_utils/test_spec
import youid/uuid

pub fn evaluate_result_error_test_() {
  use <- test_spec.make_with_timeout(timeout)
  "function test_exception(node) { throw new Error('Test exception'); }"
  |> call_with_function
  |> filter_uuid_from_remote_value
  |> pretty_print
  |> birdie.snap(
    title: "When javascript throws,
  call_function should return an exception value",
  )
}

pub fn evaluate_result_node_value_test_() {
  use <- test_spec.make_with_timeout(timeout)
  "function test_node_value(node) { return node; }"
  |> call_with_function
  |> filter_uuid_from_remote_value
  |> pretty_print
  |> birdie.snap(
    title: "When javascript returns a node value,
  call_function should return a node remote value",
  )
}

pub fn evaluate_result_undefined_test_() {
  use <- test_spec.make_with_timeout(timeout)
  "function test_undefined(node) { return undefined; }"
  |> call_with_function
  |> pretty_print
  |> birdie.snap(
    title: "When javascript returns undefined,
  call_function should return an Undefined primitive value",
  )
}

pub fn evaluate_result_null_test_() {
  use <- test_spec.make_with_timeout(timeout)
  "function test_null(node) { return null; }"
  |> call_with_function
  |> pretty_print
  |> birdie.snap(
    title: "When javascript returns null,
  call_function should return a Null primitive value",
  )
}

pub fn evaluate_result_string_test_() {
  use <- test_spec.make_with_timeout(timeout)
  "function test_string(node) { return 'Hello World'; }"
  |> call_with_function
  |> pretty_print
  |> birdie.snap(
    title: "When javascript returns a string,
  call_function should return a String primitive value",
  )
}

pub fn evaluate_result_empty_string_test_() {
  use <- test_spec.make_with_timeout(timeout)
  "function test_empty_string(node) { return ''; }"
  |> call_with_function
  |> pretty_print
  |> birdie.snap(
    title: "When javascript returns an empty string,
  call_function should return an empty String primitive value",
  )
}

pub fn evaluate_result_integer_test_() {
  use <- test_spec.make_with_timeout(timeout)
  "function test_integer(node) { return 42; }"
  |> call_with_function
  |> pretty_print
  |> birdie.snap(
    title: "When javascript returns an integer,
  call_function should return an Int Number primitive value",
  )
}

pub fn evaluate_result_float_test_() {
  use <- test_spec.make_with_timeout(timeout)
  "function test_float(node) { return 3.14159; }"
  |> call_with_function
  |> pretty_print
  |> birdie.snap(
    title: "When javascript returns a float,
  call_function should return a Float Number primitive value",
  )
}

pub fn evaluate_result_negative_zero_test_() {
  use <- test_spec.make_with_timeout(timeout)
  "function test_negative_zero(node) { return -0; }"
  |> call_with_function
  |> pretty_print
  |> birdie.snap(
    title: "When javascript returns negative zero,
  call_function should return a NegativeZero special Number primitive value",
  )
}

pub fn evaluate_result_infinity_test_() {
  use <- test_spec.make_with_timeout(timeout)
  "function test_infinity(node) { return Infinity; }"
  |> call_with_function
  |> pretty_print
  |> birdie.snap(
    title: "When javascript returns Infinity,
  call_function should return an Infinity special Number primitive value",
  )
}

pub fn evaluate_result_negative_infinity_test_() {
  use <- test_spec.make_with_timeout(timeout)
  "function test_negative_infinity(node) { return -Infinity; }"
  |> call_with_function
  |> pretty_print
  |> birdie.snap(
    title: "When javascript returns negative Infinity,
  call_function should return a NegativeInfinity special Number primitive value",
  )
}

pub fn evaluate_result_nan_test_() {
  use <- test_spec.make_with_timeout(timeout)
  "function test_nan(node) { return NaN; }"
  |> call_with_function
  |> pretty_print
  |> birdie.snap(
    title: "When javascript returns NaN,
  call_function should return a NaN special Number primitive value",
  )
}

pub fn evaluate_result_boolean_true_test_() {
  use <- test_spec.make_with_timeout(timeout)
  "function test_boolean_true(node) { return true; }"
  |> call_with_function
  |> pretty_print
  |> birdie.snap(
    title: "When javascript returns true,
  call_function should return a Boolean primitive value with true",
  )
}

pub fn evaluate_result_boolean_false_test_() {
  use <- test_spec.make_with_timeout(timeout)
  "function test_boolean_false(node) { return false; }"
  |> call_with_function
  |> pretty_print
  |> birdie.snap(
    title: "When javascript returns false,
  call_function should return a Boolean primitive value with false",
  )
}

pub fn evaluate_result_bigint_test_() {
  use <- test_spec.make_with_timeout(timeout)
  "function test_bigint(node) { return BigInt('9007199254740991'); }"
  |> call_with_function
  |> pretty_print
  |> birdie.snap(
    title: "When javascript returns a BigInt,
  call_function should return a BigInt primitive value",
  )
}

pub fn evaluate_result_bigint_large_test_() {
  use <- test_spec.make_with_timeout(timeout)
  "function test_bigint_large(node) { return BigInt('123456789012345678901234567890'); }"
  |> call_with_function
  |> pretty_print
  |> birdie.snap(
    title: "When javascript returns a large BigInt,
  call_function should return a BigInt primitive value",
  )
}

fn filter_uuid_from_remote_value(
  result: Result(EvaluateResult, ErrorResponse),
) -> Result(EvaluateResult, ErrorResponse) {
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

fn call_with_function(function: String) -> Result(EvaluateResult, ErrorResponse) {
  driver.new(Firefox)
  |> get.node(by.xpath("/html"))
  |> node.call_function(function)
  |> driver.close()
}
