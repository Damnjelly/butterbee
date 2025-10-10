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
