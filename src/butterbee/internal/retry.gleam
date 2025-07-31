import birl
import birl/duration
import gleam/erlang/process
import gleam/int
import logging

const max_wait_time = 20_000

pub fn till_true(
  retry_function: fn() -> result,
  condition: fn(result) -> Bool,
) -> result {
  retry_loop(retry_function, condition, birl.now(), 0)
}

fn retry_loop(
  retry_function: fn() -> result,
  condition: fn(result) -> Bool,
  time_started: birl.Time,
  attempts: Int,
) -> result {
  let a = retry_function()
  case condition(a) {
    True -> a
    False ->
      case
        // If time has passed, return the result
        birl.add(time_started, duration.milli_seconds(max_wait_time))
        |> birl.has_occured()
      {
        True -> {
          logging.log(logging.Warning, "Retry timed out")
          a
        }
        False -> {
          let wait_time = case attempts {
            0 -> 50
            1 -> 100
            2 -> 200
            3 -> 200
            4 -> 500
            5 -> 500
            _ -> 1000
          }
          process.sleep(wait_time)

          let counter = attempts + 1

          logging.log(
            logging.Debug,
            "Attempt failed, retrying, current attempt: "
              <> int.to_string(counter),
          )
          retry_loop(retry_function, condition, time_started, counter)
        }
      }
  }
}
