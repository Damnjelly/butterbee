import birl
import birl/duration
import gleam/erlang/process
import gleam/int
import logging

const max_wait_time = 20_000

pub fn until_ok(
  retry_function: fn() -> result,
  condition: fn(result) -> Result(a, b),
) -> result {
  result_loop(retry_function, condition, birl.now(), 1)
}

fn result_loop(
  retry_function: fn() -> result,
  condition: fn(result) -> Result(a, b),
  time_started: birl.Time,
  attempts: Int,
) -> result {
  let a = retry_function()
  case condition(a) {
    Ok(_) -> a
    Error(_) ->
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
          wait_on_attempts(attempts)

          log_attempts(attempts)

          result_loop(retry_function, condition, time_started, attempts + 1)
        }
      }
  }
}

pub fn until_true(
  retry_function: fn() -> result,
  condition: fn(result) -> Bool,
) -> result {
  bool_loop(retry_function, condition, birl.now(), 1)
}

fn bool_loop(
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
          wait_on_attempts(attempts)

          log_attempts(attempts)

          bool_loop(retry_function, condition, time_started, attempts + 1)
        }
      }
  }
}

fn wait_on_attempts(attempts: Int) -> Nil {
  let wait_time = case attempts {
    0 | 1 -> 50
    2 | 3 -> 100
    4 | 5 -> 200
    6 | 7 -> 500
    _ -> 1000
  }
  process.sleep(wait_time)
}

fn log_attempts(attempts: Int) -> Nil {
  logging.log(
    logging.Debug,
    "Attempt failed, retrying, current attempt: " <> int.to_string(attempts),
  )
}

pub fn incremented(value: Int, condition: fn(Int) -> Bool) -> Int {
  case condition(value) {
    True -> value
    False -> incremented(value + 1, condition)
  }
}
