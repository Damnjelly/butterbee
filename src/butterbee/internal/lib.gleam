import gleam/dict
import gleam/dynamic.{type Dynamic}
import gleam/list
import gleam/string
import logging
import tom

/// 
/// Returns the first element of the list, or an error if the list is empty or has more than one element.
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
    _ -> {
      logging.log(
        logging.Error,
        "Could not unwrap value: " <> string.inspect(value) <> "
     Replacing with empty string",
      )

      dynamic.string("")
    }
  }
}
