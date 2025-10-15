import butterlib/log
import gleam/erlang/process
import gleam/int
import gleam/order
import gleam/string
import gleam/time/duration
import gleam/time/timestamp.{type Timestamp}

const max_wait_time = 20_000

///
/// Retry a function until it returns a result that satisfies a condition that returns a Result
///
pub fn until_ok(
  retry_function: fn() -> Result(a, b),
  callback: fn(a) -> return_type,
) -> return_type {
  let final_result =
    result_loop(
      retry_function,
      fn(r) {
        case r {
          Ok(_) -> False
          // Success, don't continue
          Error(_) -> True
          // Error, continue retrying
        }
      },
      timestamp.system_time(),
      1,
    )
  case final_result {
    Ok(value) -> callback(value)
    // This should rarely happen (only on timeout)
    Error(err) -> {
      let err = string.inspect(err)
      panic as err
    }
  }
}

fn result_loop(
  retry_function: fn() -> Result(a, b),
  should_continue: fn(Result(a, b)) -> Bool,
  timeout: Timestamp,
  attempts: Int,
) -> Result(a, b) {
  let result = retry_function()
  case should_continue(result) {
    False -> result
    True ->
      case timestamp.compare(timeout, timestamp.system_time()) {
        order.Gt | order.Eq ->
          log.warning_and_continue("Retry timed out", result)
        order.Lt -> {
          wait_on_attempts(attempts)
          log_attempts(attempts)
          result_loop(retry_function, should_continue, timeout, attempts + 1)
        }
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
  let timeout =
    timestamp.add(timestamp.system_time(), duration.milliseconds(max_wait_time))
  bool_loop(retry_function, timeout, 1)
  callback()
}

fn bool_loop(
  retry_function: fn() -> Bool,
  timeout: Timestamp,
  attempts: Int,
) -> Nil {
  case retry_function() {
    True -> Nil
    False -> {
      case timestamp.compare(timeout, timestamp.system_time()) {
        order.Gt | order.Eq -> {
          log.warning("Retry timed out")
          Nil
        }
        order.Lt -> {
          wait_on_attempts(attempts)
          log_attempts(attempts)
          bool_loop(retry_function, timeout, attempts + 1)
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
