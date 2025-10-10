import gleam/dynamic
import gleam/erlang/atom.{type Atom}
import logging

pub fn info(msg: String) -> Nil {
  logging.log(logging.Info, msg)
}

pub fn warning(msg: String) -> Nil {
  logging.log(logging.Warning, msg)
}

pub fn debug(msg: String) -> Nil {
  logging.log(logging.Debug, msg)
}

pub fn error(msg: String) -> Nil {
  logging.log(logging.Error, msg)
}

///
/// Logs an Info log and return a value
/// Useful for when you want to log an info log before returning a value
///
pub fn info_and_continue(msg: String, continue: a) -> a {
  info(msg)
  continue
}

/// 
/// Logs an Warning log and return a value
/// Useful for when you want to log a warning before returning a value
///
pub fn warning_and_continue(msg: String, continue: a) -> a {
  warning(msg)
  continue
}

/// 
/// Logs an Debug log and return a value
/// Useful for when you want to log a debug log before returning a value
///
pub fn debug_and_continue(msg: String, continue: a) -> a {
  debug(msg)
  continue
}

///
/// Creates an Error log and return the given value 'a'
/// Useful for when you want to log an error before returning a value
///
pub fn error_and_continue(msg: String, continue: a) -> a {
  error(msg)
  continue
}

const filters = [
  "WebSocket handshake failed: Sock\\(Econnrefused\\)", "Making request",
]

pub fn configure(loglevel: logging.LogLevel) {
  logging.configure()
  logging.set_level(loglevel)

  let _ = add_primary_filters(filters)
}

@external(erlang, "logger", "set_application_level")
fn set_application_level(app: Atom, level: Atom) -> Result(Nil, Nil)

///
/// Suppress SASL application logs specifically
/// This removeds the Error Reports from erlang logging
///
pub fn suppress_sasl_error_reports() {
  let sasl = atom.cast_from_dynamic(dynamic.string("sasl"))
  let level = atom.cast_from_dynamic(dynamic.string("none"))

  set_application_level(sasl, level)
}

@external(erlang, "log_ffi", "add_primary_inspect")
pub fn add_primary_inspect() -> Nil

@external(erlang, "log_ffi", "add_primary_filters")
pub fn add_primary_filters(patterns: List(String)) -> Nil
