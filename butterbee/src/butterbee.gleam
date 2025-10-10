import butterbee/internal/log
import logging
import simplifile

///
/// Initialize butterbee,
/// Call this in the main function of your test, before calling gleeunit.main
///
pub fn init() {
  let _ = log.suppress_sasl_error_reports()
  logging.log(logging.Debug, "Initializing butterbee")

  logging.log(logging.Debug, "Deleting data_dir")
  let _ = simplifile.delete("/tmp/butterbee")

  Nil
}
