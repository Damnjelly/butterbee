import gleam/bool
import gleam/dynamic.{type Dynamic}
import gleam/dynamic/decode
import gleam/float
import gleam/int
import logging

pub type PrimitiveProtocolValue {
  Undefined(UndefinedValue)
  Null(NullValue)
  String(StringValue)
  Number(NumberValue)
  Boolean(BooleanValue)
  BigInt(BigIntValue)
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

pub type UndefinedValue {
  UndefinedValue(remote_type: String)
}

pub type NullValue {
  NullValue(remote_type: String)
}

pub type StringValue {
  StringValue(remote_type: String, value: String)
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
    _ -> {
      logging.log(logging.Warning, "Unknown special number: " <> variant)
      NaN
    }
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

pub type NumberValue {
  NumberValue(remote_type: String, value: Number)
}

pub fn number_value_classifier(value: Dynamic) -> Number {
  case dynamic.classify(value) {
    "Int" ->
      case decode.run(value, decode.int) {
        Ok(int) -> Int(int)
        Error(_) -> {
          logging.log(logging.Warning, "Failed to decode Int")
          Special(NaN)
        }
      }
    "Float" ->
      case decode.run(value, decode.float) {
        Ok(float) -> Float(float)
        Error(_) -> {
          logging.log(logging.Warning, "Failed to decode Float")
          Special(NaN)
        }
      }
    "String" ->
      case decode.run(value, decode.string) {
        Ok(string) -> Special(string_to_special_number(string))
        Error(_) -> {
          logging.log(logging.Warning, "Failed to decode String")
          Special(NaN)
        }
      }
    _ -> {
      logging.log(
        logging.Warning,
        "Unknown number type: " <> dynamic.classify(value),
      )
      Special(NaN)
    }
  }
}

pub type BooleanValue {
  BooleanValue(remote_type: String, value: Bool)
}

pub type BigIntValue {
  BigIntValue(remote_type: String, value: String)
}
