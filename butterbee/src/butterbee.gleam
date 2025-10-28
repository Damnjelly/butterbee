import butterlib/log
import simplifile

/// Initialize butterbee,
/// Call this in the main function of your test, before calling gleeunit.main.
/// Then call [`driver.new`](https://hexdocs.pm/butterbee/driver.html#new) in your test
/// to start using butterbee.
pub fn init() {
  log.debug("Initializing butterbee")
  let _ = log.suppress_sasl_error_reports()

  log.debug("Deleting data_dir")
  //TODO: actually delete data_dir instead of hardcoding it
  let _ = simplifile.delete("/tmp/butterbee")

  Nil
}
