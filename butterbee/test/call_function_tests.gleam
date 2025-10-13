import birdie
import butterbee/by
import butterbee/config/browser.{Firefox}
import butterbee/nodes
import butterbee/query
import butterbee/webdriver
import butterbee_test
import qcheck_gleeunit_utils/test_spec

pub fn evaluate_result_exception_test_() {
  use <- test_spec.make_with_timeout(butterbee_test.timeout)
  let function =
    "function test_exception(node) { throw new Error('Test exception'); }"

  let result =
    webdriver.new(Firefox)
    |> query.node(by.xpath("/html"))
    |> nodes.call_function(function)
    |> webdriver.close()

  birdie.snap(
    title: "When javascript throws, call_function should return an exception",
    content: butterbee_test.pretty_print(result),
  )
}
