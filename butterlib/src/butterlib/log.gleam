import gleam/dynamic
import palabres
import palabres/level.{type Level}
import palabres/options

@target(erlang)
import gleam/erlang/atom.{type Atom}

fn palabres_configure(loglevel: Level) {
  options.defaults()
  |> options.level(loglevel)
  |> palabres.configure
}

@target(erlang)
pub fn configure(loglevel: Level) {
  palabres_configure(loglevel)
  suppress_sasl_error_reports()
  add_primary_filters(filters)
}

const filters = [
  "WebSocket handshake failed: Sock\\(Econnrefused\\)", "Making request",
]

@target(erlang)
@external(erlang, "logger", "set_application_level")
fn set_application_level(app: Atom, level: Atom) -> Result(Nil, Nil)

@target(erlang)
/// Suppress SASL application logs specifically
/// This removeds the Error Reports from erlang logging
/// These showed up when connecting to browser using stratus before the browser was ready
pub fn suppress_sasl_error_reports() -> Nil {
  let sasl = atom.cast_from_dynamic(dynamic.string("sasl"))
  let level = atom.cast_from_dynamic(dynamic.string("none"))

  let _ = set_application_level(sasl, level)
  Nil
}

@external(erlang, "log_ffi", "add_primary_inspect")
pub fn add_primary_inspect() -> Nil

@external(erlang, "log_ffi", "add_primary_filters")
pub fn add_primary_filters(patterns: List(String)) -> Nil
