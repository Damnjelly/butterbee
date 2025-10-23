import glam/doc.{type Document}
import gleam/bool
import gleam/dict
import gleam/dynamic.{type Dynamic}
import gleam/dynamic/decode
import gleam/float
import gleam/int
import gleam/json
import gleam/list
import gleam/string

const line_length = 40

const indent_size = 2

pub type TypedJson {
  String(String)
  Float(Float)
  Int(Int)
  Bool(Bool)
  Array(List(TypedJson))
  Object(List(#(String, TypedJson)))
  Null
}

pub fn pretty_json(json msg: String) -> String {
  case json.parse(msg, decode.dynamic) {
    Error(error) -> "Error decoding json: " <> string.inspect(error)
    Ok(json) ->
      dynamic_to_doc(json)
      |> doc.to_string(line_length)
  }
}

pub fn dynamic_to_doc(json: Dynamic) -> Document {
  dynamic_to_typed_json(json)
  |> typed_json_to_doc
}

fn dynamic_to_typed_json(dyn: Dynamic) -> TypedJson {
  case dynamic.classify(dyn) {
    "String" -> {
      case decode.run(dyn, decode.string) {
        Ok(str) -> String(str)
        Error(_) -> Null
      }
    }

    "Int" -> {
      case decode.run(dyn, decode.int) {
        Ok(int) -> Int(int)
        Error(_) -> Null
      }
    }

    "Float" -> {
      case decode.run(dyn, decode.float) {
        Ok(float) -> Float(float)
        Error(_) -> Null
      }
    }

    "Bool" -> {
      case decode.run(dyn, decode.bool) {
        Ok(bool) -> Bool(bool)
        Error(_) -> Null
      }
    }

    "List" -> {
      case decode.run(dyn, decode.list(decode.dynamic)) {
        Ok(list) -> {
          list
          |> list.map(dynamic_to_typed_json)
          |> Array
        }
        Error(_) -> Null
      }
    }

    "Dict" -> {
      case decode.run(dyn, decode.dict(decode.string, decode.dynamic)) {
        Ok(dict_val) -> {
          dict_val
          |> dict.to_list
          |> list.map(fn(pair) {
            let #(key, value) = pair
            #(key, dynamic_to_typed_json(value))
          })
          |> Object
        }
        Error(_) -> Null
      }
    }

    "Null" -> Null

    _ -> Null
  }
}

pub fn typed_json_to_doc(json: TypedJson) -> Document {
  case json {
    String(string) -> doc.from_string("\"" <> string <> "\"")
    Float(number) -> doc.from_string(float.to_string(number))
    Int(number) -> doc.from_string(int.to_string(number))
    Bool(bool) -> bool_to_doc(bool)
    Null -> doc.from_string("null")
    Array(objects) -> array_to_doc(objects)
    Object(fields) -> object_to_doc(fields)
  }
}

fn bool_to_doc(bool: Bool) -> Document {
  bool.to_string(bool)
  |> string.lowercase
  |> doc.from_string
}

fn array_to_doc(objects: List(TypedJson)) -> Document {
  list.map(objects, typed_json_to_doc)
  |> doc.concat_join(with: [comma(), doc.space])
  |> parenthesise("[", "]")
}

fn field_to_doc(field: #(String, TypedJson)) -> Document {
  let #(name, value) = field
  let name_doc = doc.from_string(name)
  let value_doc = typed_json_to_doc(value)
  [name_doc, colon(), doc.from_string(" "), value_doc]
  |> doc.concat
}

fn object_to_doc(fields: List(#(String, TypedJson))) -> Document {
  list.map(fields, field_to_doc)
  |> doc.concat_join(with: [comma(), doc.space])
  |> parenthesise("{", "}")
}

fn colon() -> Document {
  doc.from_string(":")
}

fn comma() -> Document {
  doc.from_string(",")
}

fn parenthesise(document: Document, open: String, close: String) -> Document {
  document
  |> doc.prepend_docs([doc.from_string(open), doc.space])
  |> doc.nest(by: indent_size)
  |> doc.append_docs([doc.space, doc.from_string(close)])
  |> doc.group
}
