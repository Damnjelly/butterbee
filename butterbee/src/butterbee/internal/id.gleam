import gleam/time/timestamp

pub fn from_unix() -> Int {
  let #(_seconds, nanoseconds) =
    timestamp.to_unix_seconds_and_nanoseconds(timestamp.system_time())
  nanoseconds
}
