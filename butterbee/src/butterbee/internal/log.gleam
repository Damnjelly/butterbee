import palabres
import palabres/level.{type Level}
import palabres/options

pub fn configure(loglevel: Level) {
  options.defaults()
  |> options.level(loglevel)
  |> palabres.configure
}

pub const filters = [
  "WebSocket handshake failed: Sock\\(Econnrefused\\)", "Making request",
]

@external(erlang, "log_ffi", "add_primary_filters")
pub fn add_primary_filters(patterns: List(String)) -> Nil
