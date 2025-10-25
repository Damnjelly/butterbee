import butterbee/commands/script
import butterbee/internal/error
import butterbee/internal/retry
import butterbee/webdriver.{type WebDriver}
import butterbidi/script/commands/call_function
import butterbidi/script/types/evaluate_result.{type EvaluateResult}
import butterbidi/script/types/local_value.{type LocalValue}
import butterbidi/script/types/remote_value
import butterbidi/script/types/target
import gleam/list
import gleam/option.{type Option, None, Some}

pub fn abstract(
  driver: WebDriver(state),
  this: Option(LocalValue),
  arguments: List(LocalValue),
  function: String,
) -> Result(EvaluateResult, error.ButterbeeError) {
  case webdriver.get_context(driver) {
    Error(error) -> Error(error)
    Ok(context) -> {
      let target = target.new_context_target(context)

      let params =
        call_function.new(target)
        |> call_function.with_function(function)
        |> call_function.with_arguments(arguments)

      let params = case this {
        None -> params
        Some(this) -> call_function.with_this(params, this)
      }

      retry.until_ok(fn() { script.call_function(driver, params) })
    }
  }
}

pub fn static(
  driver: WebDriver(state),
  arguments: List(LocalValue),
  function: String,
) -> Result(EvaluateResult, error.ButterbeeError) {
  abstract(driver, option.None, arguments, function)
}

pub fn on_node(
  driver: WebDriver(remote_value.NodeRemoteValue),
  arguments: List(LocalValue),
  function: String,
) {
  driver
  |> webdriver.with_state({
    case driver.state {
      Error(error) -> Error(error)
      Ok(node) -> Ok(local_value.node(node))
    }
  })
  |> on_value(arguments, function)
}

pub fn on_nodes(
  driver: WebDriver(List(remote_value.NodeRemoteValue)),
  arguments: List(LocalValue),
  function: String,
) {
  driver
  |> webdriver.with_state({
    case driver.state {
      Error(error) -> Error(error)
      Ok(nodes) -> {
        case
          list.try_map(nodes, fn(node) {
            let value = local_value.node(node)
            case value {
              local_value.RemoteReference(_) -> Ok(value)
              _ -> Error(error.CouldNotConvertToLocalValue)
            }
          })
        {
          Error(error) -> Error(error)
          Ok(nodes) -> Ok(local_value.array(nodes))
        }
      }
    }
  })
  |> on_value(arguments, function)
}

pub fn on_value(
  driver: WebDriver(LocalValue),
  arguments: List(LocalValue),
  function: String,
) -> Result(EvaluateResult, error.ButterbeeError) {
  case driver.state {
    Error(error) -> Error(error)
    Ok(local_value) -> {
      abstract(driver, Some(local_value), arguments, function)
    }
  }
}

pub fn result_to_string(result: Result(EvaluateResult, error.ButterbeeError)) {
  case result {
    Error(error) -> Error(error)
    Ok(evaluate_result) ->
      case evaluate_result {
        evaluate_result.SuccessResult(success) ->
          Ok(remote_value.to_string(success.result))
        evaluate_result.ExceptionResult(exception) -> {
          Ok(remote_value.to_string(exception.exception_details.exception))
        }
      }
  }
}

pub fn result_to_string_list(
  result_list: Result(EvaluateResult, error.ButterbeeError),
) -> Result(List(String), error.ButterbeeError) {
  case result_list {
    Error(error) -> Error(error)
    Ok(evaluate_result) ->
      case evaluate_result {
        evaluate_result.SuccessResult(success) ->
          Ok(remote_value.to_string_list(success.result))
        evaluate_result.ExceptionResult(exception) -> {
          Ok(remote_value.to_string_list(exception.exception_details.exception))
        }
      }
  }
}

pub fn result_to_bool(result: Result(EvaluateResult, error.ButterbeeError)) {
  case result {
    Error(error) -> Error(error)
    Ok(evaluate_result) ->
      case evaluate_result {
        evaluate_result.SuccessResult(success) ->
          Ok(remote_value.to_bool(success.result))
        evaluate_result.ExceptionResult(exception) -> {
          Error(
            error.ToBoolError(remote_value.to_string(
              exception.exception_details.exception,
            )),
          )
        }
      }
  }
}
