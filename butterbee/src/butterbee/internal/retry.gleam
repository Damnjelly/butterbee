import birl
import birl/duration
import butterlib/log
import gleam/erlang/process
import gleam/int

const max_wait_time = 20_000

/// Retry a function until it returns a result that satisfies a condition that returns a Result
pub fn until_ok(
  retry_function: fn() -> result,
  condition: fn(result) -> Result(a, b),
) -> result {
  result_loop(retry_function, condition, birl.now(), 1)
}

/// Retry a function until it returns a result that satisfies a condition that returns a Bool
pub fn until_true(
  retry_function: fn() -> result,
  condition: fn(result) -> Bool,
) -> result {
  bool_loop(retry_function, condition, birl.now(), 1)
}

// Generic retry loop that handles the common logic
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

// Wrapper for Result-based conditions
fn result_loop(
  retry_function: fn() -> result,
  condition: fn(result) -> Result(a, b),
  time_started: birl.Time,
  attempts: Int,
) -> result {
  retry_loop(
    retry_function,
    fn(r) {
      case condition(r) {
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

// Wrapper for Bool-based conditions
fn bool_loop(
  retry_function: fn() -> result,
  condition: fn(result) -> Bool,
  time_started: birl.Time,
  attempts: Int,
) -> result {
  retry_loop(
    retry_function,
    fn(r) { !condition(r) },
    // Invert because True means success, False means retry
    time_started,
    attempts,
  )
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
