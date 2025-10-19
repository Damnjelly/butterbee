import butterlib/log
import gleam/bool
import gleam/dict
import gleam/dynamic.{type Dynamic}
import gleam/dynamic/decode
import gleam/float
import gleam/int
import gleam/list
import gleam/string
import tom

pub const definition_error = "Butterbee error"

/// 
/// Returns the first element of the list, or an error if the list is empty
/// 
pub fn single_element(list: List(a)) -> Result(a, String) {
  case list {
    [element] -> Ok(element)
    [] -> Error("List is empty")
    _ -> Error("List has more than one element")
  }
}

///
/// unwraps a toml document into a dynamic document
///
pub fn toml_to_dynamic(value: tom.Toml) -> Dynamic {
  case value {
    tom.String(value) -> dynamic.string(value)
    tom.Int(value) -> dynamic.int(value)
    tom.Float(value) -> dynamic.float(value)
    tom.Bool(value) -> dynamic.bool(value)
    tom.Array(value) -> dynamic.array({ list.map(value, toml_to_dynamic) })
    tom.InlineTable(value) | tom.Table(value) ->
      dynamic.properties({
        value
        |> dict.to_list()
        |> list.map(fn(entry) {
          let #(key, value) = entry
          #(dynamic.string(key), toml_to_dynamic(value))
        })
      })
    tom.ArrayOfTables(value) -> {
      dynamic.array({
        list.map(value, fn(table) { toml_to_dynamic(tom.Table(table)) })
      })
    }
    _ ->
      log.error_and_continue(
        "Could not unwrap value: "
          <> string.inspect(value)
          <> " Replacing with empty string",
        dynamic.string(""),
      )
  }
}

pub fn dynamic_to_string(dyn: Dynamic) -> String {
  case dynamic.classify(dyn) {
    "String" -> {
      case decode.run(dyn, decode.string) {
        Ok(str) -> str
        Error(_) -> ""
      }
    }

    "Int" -> {
      case decode.run(dyn, decode.int) {
        Ok(int) -> int.to_string(int)
        Error(_) -> ""
      }
    }

    "Float" -> {
      case decode.run(dyn, decode.float) {
        Ok(float) -> float.to_string(float)
        Error(_) -> ""
      }
    }

    "Bool" -> {
      case decode.run(dyn, decode.bool) {
        Ok(bool) -> bool.to_string(bool) |> string.lowercase
        Error(_) -> ""
      }
    }
    _ ->
      log.error_and_continue(
        "Could not convert dynamic to string, value: "
          <> string.inspect(dyn)
          <> " replacing with empty string",
        "",
      )
  }
}
