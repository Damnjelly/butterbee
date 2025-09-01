import gleam/erlang/process
import gleam/http/request
import logging
import simplifile
import stratus

pub fn init() {
  logging.log(logging.Debug, "Initializing butterbee")

  logging.log(logging.Debug, "Deleteing data_dir")
  simplifile.delete("/tmp/butterbee")
}

pub fn main() {
  logging.configure()
  logging.set_level(logging.Debug)
  let assert Ok(req) = request.to("http://localhost:3000")
  let builder =
    stratus.new(req, Nil)
    |> stratus.on_message(fn(state, msg, _conn) {
      case msg {
        stratus.Text(msg) -> {
          logging.log(logging.Info, "Got a message: " <> msg)
          stratus.continue(state)
        }
        stratus.Binary(_msg) -> stratus.continue(state)
        stratus.User(_) -> {
          stratus.stop()
        }
      }
    })
    |> stratus.start
    |> echo

  process.sleep(100)
}
