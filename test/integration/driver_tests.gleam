import butterbee/driver

pub fn wait_test() {
  let driver = driver.new()

  let first_url =
    driver.get_url(driver)
    |> driver.wait(2000)
    |> driver.value

  let second_url =
    driver.goto(driver, "https://gleam.run/")
    |> driver.get_url()
    |> driver.close()

  assert #(first_url, second_url) == #("about:home", "https://gleam.run/")
}
