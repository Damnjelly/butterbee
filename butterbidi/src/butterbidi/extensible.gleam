import gleam/dict.{type Dict}
import gleam/dynamic.{type Dynamic}
import gleam/dynamic/decode
import gleam/json.{type Json}
import gleam/list
import gleam/string
import palabres as log

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
            log.error("Could not decode string")
            |> log.string("error", string.inspect(error))
            |> log.string("value", string.inspect(value))
            |> log.log
            json.null()
          }
        }
      }
      "Int" -> {
        case decode.run(value, decode.int) {
          Ok(value) -> json.int(value)
          Error(error) -> {
            log.error("Could not decode int")
            |> log.string("error", string.inspect(error))
            |> log.string("value", string.inspect(value))
            |> log.log
            json.null()
          }
        }
      }
      "Float" -> {
        case decode.run(value, decode.float) {
          Ok(value) -> json.float(value)
          Error(error) -> {
            log.error("Could not decode float")
            |> log.string("error", string.inspect(error))
            |> log.string("value", string.inspect(value))
            |> log.log
            json.null()
          }
        }
      }
      "Bool" -> {
        case decode.run(value, decode.bool) {
          Ok(value) -> json.bool(value)
          Error(error) -> {
            log.error("Could not decode bool")
            |> log.string("error", string.inspect(error))
            |> log.string("value", string.inspect(value))
            |> log.log
            json.null()
          }
        }
      }
      "Dict" -> {
        case decode.run(value, decode.dict(decode.string, decode.dynamic)) {
          Ok(value) -> json.object(extensible_to_list(value))
          Error(error) -> {
            log.error("Could not decode dynamic")
            |> log.string("error", string.inspect(error))
            |> log.string("value", string.inspect(value))
            |> log.log
            json.null()
          }
        }
      }
      _ -> {
        log.error("Unknown extensible type")
        |> log.string("type", dynamic.classify(value))
        |> log.log
        json.null()
      }
    }

    #(key, value)
  })
}
