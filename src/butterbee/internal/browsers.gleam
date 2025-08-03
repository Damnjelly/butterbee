import gleam/dict.{type Dict}
import gleam/dynamic.{type Dynamic}

pub type Browsers {
  Firefox(host: String, port_range: #(Int, Int))
  Chrome(host: String, port_range: #(Int, Int))
}
