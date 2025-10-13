import birl
import birl/duration
import butterlib/log
import gleam/erlang/process
import gleam/int
import gleam/string

const max_wait_time = 20_000

///
/// Retry a function until it returns a result that satisfies a condition that returns a Result
///
pub fn until_ok(
  retry_function: fn() -> Result(a, b),
  callback: fn(a) -> return_type,
) -> return_type {
  let final_result = result_loop(retry_function, birl.now(), 1)
  case final_result {
    Ok(value) -> callback(value)
    // This should rarely happen (only on timeout)
    Error(err) -> {
      let err = string.inspect(err)
      panic as err
    }
  }
}

///
/// Retry a function until it returns a result that satisfies a condition that returns a Bool
/// Panics if the function never returns true
///
pub fn until_true(
  retry_function: fn() -> Bool,
  callback: fn() -> return_type,
) -> return_type {
  let _ = bool_loop(retry_function, birl.now(), 1)
  callback()
}

fn retry_loop(
  retry_function: fn() -> result,
  should_continue: fn(result) -> Bool,
  time_started: birl.Time,
  attempts: Int,
) -> result {
  let a = retry_function()
  case should_continue(a) {
    False -> a
    // Success condition met
    True ->
      // Need to retry
      case
        // If time has passed, return the result
        birl.add(time_started, duration.milli_seconds(max_wait_time))
        |> birl.has_occured()
      {
        True -> log.warning_and_continue("Retry timed out", a)
        False -> {
          wait_on_attempts(attempts)
          log_attempts(attempts)
          retry_loop(
            retry_function,
            should_continue,
            time_started,
            attempts + 1,
          )
        }
      }
  }
}

fn result_loop(
  retry_function: fn() -> Result(a, b),
  time_started: birl.Time,
  attempts: Int,
) -> Result(a, b) {
  retry_loop(
    retry_function,
    fn(r) {
      case r {
        Ok(_) -> False
        // Success, don't continue
        Error(_) -> True
        // Error, continue retrying
      }
    },
    time_started,
    attempts,
  )
}

fn bool_loop(
  retry_function: fn() -> Bool,
  time_started: birl.Time,
  attempts: Int,
) -> Nil {
  let result = retry_function()
  case result {
    True -> Nil
    // Success, stop retrying
    False -> {
      // Need to retry
      case
        birl.add(time_started, duration.milli_seconds(max_wait_time))
        |> birl.has_occured()
      {
        True -> {
          log.warning("Retry timed out")
          Nil
        }
        False -> {
          wait_on_attempts(attempts)
          log_attempts(attempts)
          bool_loop(retry_function, time_started, attempts + 1)
        }
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
  log.debug(
    "Connection attempt failed, retrying, current attempt: "
    <> int.to_string(attempts),
  )
}

/// Increment a value until a condition is met
pub fn incremented(value: Int, condition: fn(Int) -> Bool) -> Int {
  incremented_loop(value, condition)
}

fn incremented_loop(value: Int, condition: fn(Int) -> Bool) -> Int {
  case condition(value) {
    True -> value
    False -> incremented(value + 1, condition)
  }
}
