import envoy
import gleam/result
import shellout

pub fn echo_json(body: String) -> Nil {
  let assert Ok(cmd) = envoy.get("JSONFORMAT")

  shellout.command(run: cmd, with: [body], in: ".", opt: [shellout.LetBeStdout])
  |> result.map(with: fn(_out) { 0 })
  |> result.map_error(with: fn(_det) { 1 })
  |> result.unwrap_both

  Nil
}
