import butterlib/log
import gleam/bool
import gleam/dynamic.{type Dynamic}
import gleam/dynamic/decode
import gleam/float
import gleam/int
import gleam/json.{type Json}

pub type PrimitiveProtocolValue {
  Undefined(UndefinedValue)
  Null(NullValue)
  String(StringValue)
  Number(NumberValue)
  Boolean(BooleanValue)
  BigInt(BigIntValue)
}

pub fn primitive_protocol_value_to_json(value: PrimitiveProtocolValue) -> Json {
  case value {
    Undefined(UndefinedValue(remote_type)) ->
      json.object([
        #("type", json.string(remote_type)),
        #("value", json.string("undefined")),
      ])
    Null(NullValue(remote_type)) ->
      json.object([
        #("type", json.string(remote_type)),
        #("value", json.string("null")),
      ])
    String(StringValue(remote_type, value)) ->
      json.object([
        #("type", json.string(remote_type)),
        #("value", json.string(value)),
      ])
    Number(NumberValue(remote_type, value)) ->
      json.object([
        #("type", json.string(remote_type)),
        #("value", number_to_json(value)),
      ])
    Boolean(BooleanValue(remote_type, value)) ->
      json.object([
        #("type", json.string(remote_type)),
        #("value", json.bool(value)),
      ])
    BigInt(BigIntValue(remote_type, value)) ->
      json.object([
        #("type", json.string(remote_type)),
        #("value", json.string(value)),
      ])
  }
}

pub fn to_string(value: PrimitiveProtocolValue) -> String {
  case value {
    Undefined(_) -> "undefined"
    Null(_) -> "null"
    String(value) -> value.value
    Number(value) -> number_to_string(value.value)
    Boolean(value) -> bool.to_string(value.value)
    BigInt(value) -> value.value
  }
}

pub fn to_bool(value: PrimitiveProtocolValue) -> Bool {
  case value {
    Boolean(value) -> value.value
    _ -> False
  }
}

pub type UndefinedValue {
  UndefinedValue(remote_type: String)
}

pub fn undefined() -> PrimitiveProtocolValue {
  Undefined(UndefinedValue("undefined"))
}

pub type NullValue {
  NullValue(remote_type: String)
}

pub type StringValue {
  StringValue(remote_type: String, value: String)
}

pub fn string(value: String) -> PrimitiveProtocolValue {
  String(StringValue("string", value))
}

pub type SpecialNumber {
  NaN
  NegativeZero
  Infinity
  NegativeInfinity
}

fn string_to_special_number(variant: String) -> SpecialNumber {
  case variant {
    "NaN" -> NaN
    "-0" -> NegativeZero
    "Infinity" -> Infinity
    "-Infinity" -> NegativeInfinity
    _ -> log.warning_and_continue("Unknown special number: " <> variant, NaN)
  }
}

fn special_number_to_string(special_number: SpecialNumber) -> String {
  case special_number {
    NaN -> "NaN"
    NegativeZero -> "-0"
    Infinity -> "Infinity"
    NegativeInfinity -> "-Infinity"
  }
}

pub type Number {
  Int(Int)
  Float(Float)
  Special(SpecialNumber)
}

pub fn number_to_string(number: Number) -> String {
  case number {
    Int(int) -> int.to_string(int)
    Float(float) -> float.to_string(float)
    Special(special_number) -> special_number_to_string(special_number)
  }
}

pub fn number_to_json(number: Number) -> Json {
  case number {
    Int(int) -> json.int(int)
    Float(float) -> json.float(float)
    Special(special_number) ->
      json.string(special_number_to_string(special_number))
  }
}

pub fn int(int: Int) -> PrimitiveProtocolValue {
  Number(NumberValue("number", Int(int)))
}

pub fn float(float: Float) -> PrimitiveProtocolValue {
  Number(NumberValue("number", Float(float)))
}

pub type NumberValue {
  NumberValue(remote_type: String, value: Number)
}

pub fn number_value_classifier(value: Dynamic) -> Number {
  case dynamic.classify(value) {
    "Int" ->
      case decode.run(value, decode.int) {
        Ok(int) -> Int(int)
        Error(_) ->
          log.warning_and_continue("Failed to decode Int", Special(NaN))
      }
    "Float" ->
      case decode.run(value, decode.float) {
        Ok(float) -> Float(float)
        Error(_) ->
          log.warning_and_continue("Failed to decode Float", Special(NaN))
      }
    "String" ->
      case decode.run(value, decode.string) {
        Ok(string) -> Special(string_to_special_number(string))
        Error(_) ->
          log.warning_and_continue("Failed to decode String", Special(NaN))
      }
    _ ->
      log.warning_and_continue(
        "Unknown number type: " <> dynamic.classify(value),
        Special(NaN),
      )
  }
}

pub type BooleanValue {
  BooleanValue(remote_type: String, value: Bool)
}

pub fn boolean(boolean: Bool) -> PrimitiveProtocolValue {
  Boolean(BooleanValue("boolean", boolean))
}

pub type BigIntValue {
  BigIntValue(remote_type: String, value: String)
}
