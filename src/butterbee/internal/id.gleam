import birl

pub fn from_unix() -> Int {
  birl.utc_now() |> birl.to_unix_micro()
}
