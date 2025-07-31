import gleam/result
import logging
import shellout

fn runner(program) -> Nil {
  shellout.arguments()
  |> shellout.command(run: "ls", in: ".", opt: [])
  |> result.map(with: fn(_) { 0 })
  |> result.map_error(with: fn(detail) {
    let #(status, message) = detail
    logging.log(logging.Error, message)
    status
  })
  |> result.unwrap_both
  |> shellout.exit
}
