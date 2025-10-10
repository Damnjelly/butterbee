import logging
import simplifile

///
/// Initialize butterbee,
/// Call this in the main function of your test, before calling gleeunit.main
///
pub fn init() {
  error_logger_tty(False)
  logging.log(logging.Debug, "Initializing butterbee")

  logging.log(logging.Debug, "Deleting data_dir")
  let _ = simplifile.delete("/tmp/butterbee")

  Nil
}

/// Disables the tty error logger
@external(erlang, "error_logger", "tty")
fn error_logger_tty(flag: Bool) -> Nil
