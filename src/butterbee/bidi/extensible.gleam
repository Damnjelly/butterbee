import gleam/dict.{type Dict}
import gleam/dynamic.{type Dynamic}
import gleam/dynamic/decode
import gleam/json.{type Json}
import gleam/list
import gleam/string
import logging

pub fn extensible_to_list(
  extensible: Dict(String, Dynamic),
) -> List(#(String, Json)) {
  dict.to_list(extensible)
  |> list.map(fn(entry) {
    let #(key, value) = entry
    let value = case dynamic.classify(value) {
      "String" -> {
        case decode.run(value, decode.string) {
          Ok(value) -> json.string(value)
          Error(error) -> {
            logging.log(
              logging.Error,
              "Could not decode string, error: " <> string.inspect(error),
            )
            json.null()
          }
        }
      }
      "Int" -> {
        case decode.run(value, decode.int) {
          Ok(value) -> json.int(value)
          Error(error) -> {
            logging.log(
              logging.Error,
              "Could not decode int, error: " <> string.inspect(error),
            )
            json.null()
          }
        }
      }
      "Float" -> {
        case decode.run(value, decode.float) {
          Ok(value) -> json.float(value)
          Error(error) -> {
            logging.log(
              logging.Error,
              "Could not decode float, error: " <> string.inspect(error),
            )
            json.null()
          }
        }
      }
      "Bool" -> {
        case decode.run(value, decode.bool) {
          Ok(value) -> json.bool(value)
          Error(error) -> {
            logging.log(
              logging.Error,
              "Could not decode bool, error: " <> string.inspect(error),
            )
            json.null()
          }
        }
      }
      "Dict" -> {
        case decode.run(value, decode.dict(decode.string, decode.dynamic)) {
          Ok(value) -> json.object(extensible_to_list(value))
          Error(error) -> {
            logging.log(
              logging.Error,
              "Could not decode dynamic, error: " <> string.inspect(error),
            )
            json.null()
          }
        }
      }
      _ -> {
        logging.log(
          logging.Error,
          "Could not decode dynamic, error: " <> string.inspect(value),
        )
        json.null()
      }
    }
    #(key, value)
  })
}
