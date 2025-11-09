import palabres as logger

/// Initialize butterbee,
/// Call this in the main function of your test, before calling gleeunit.main.
/// Then call [`driver.new`](https://hexdocs.pm/butterbee/driver.html#new) in your test
/// to start using butterbee.
pub fn init() {
  logger.debug("Initializing butterbee")
  |> logger.log
  logger.debug("Deleting data_dir")
  |> logger.log
  //TODO: actually delete data_dir instead of hardcoding it
  // let _ = simplifile.delete("/tmp/butterbee")

  Nil
}
