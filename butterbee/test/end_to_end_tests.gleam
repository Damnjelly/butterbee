// import butterbee/config/browser.{Firefox}
// import butterbee/input
// import butterbee/internal/test_page
// import butterbee/key
// import butterbee/nodes
// import butterbee/page
// import butterbee/webdriver
// import butterbee_test
// import gleam/string
// import qcheck_gleeunit_utils/test_spec
//
// //
// // pub fn enter_keys_test_() {
// //   use <- test_spec.make_with_timeout(butterbee_test.timeout)
// //
// //   let comments =
// //     butterbee_test.test_page(Firefox)
// //     |> test_page.comments_field()
// //     |> input.enter_keys("line1" <> key.enter <> "line2" <> key.enter)
// //     |> test_page.comments_field()
// //     |> nodes.inner_text()
// //     |> webdriver.close()
// //
// //   assert comments == "line1\nline2\n"
// // }
//
// pub fn navigation_test_() {
//   use <- test_spec.make_with_timeout(butterbee_test.timeout)
//   let driver = butterbee_test.test_page(Firefox)
//
//   let first_url =
//     page.url(driver)
//     |> webdriver.wait(1000)
//     |> webdriver.value
//     |> string.ends_with("test_page.html")
//
//   let second_url =
//     webdriver.goto(driver, "about:blank")
//     |> page.url()
//     |> webdriver.close()
//     |> string.contains("about:blank")
//
//   assert #(first_url, second_url) == #(True, True)
// }
