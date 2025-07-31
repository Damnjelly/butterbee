import gleam/json.{type Json}
import gleam/list
import gleam/option.{type Option, None, Some}

pub type SerializationOptions {
  SerializationOptions(
    max_dom_depth: Option(Option(Int)),
    max_object_depth: Option(Option(Int)),
    include_shadow_tree: Option(Option(IncludeShadowTree)),
  )
}

pub fn serialization_options_to_json(
  serialization_options: SerializationOptions,
) -> Json {
  let SerializationOptions(
    max_dom_depth:,
    max_object_depth:,
    include_shadow_tree:,
  ) = serialization_options
  let max_dom_depth = case max_dom_depth {
    None -> []
    Some(value) -> [
      #("max_dom_depth", case value {
        None -> json.null()
        Some(value) -> json.int(value)
      }),
    ]
  }
  let max_object_depth = case max_object_depth {
    None -> []
    Some(value) -> [
      #("max_object_depth", case value {
        None -> json.null()
        Some(value) -> json.int(value)
      }),
    ]
  }
  let include_shadow_tree = case include_shadow_tree {
    None -> []
    Some(value) -> [
      #("include_shadow_tree", case value {
        None -> json.null()
        Some(value) -> include_shadow_tree_to_json(value)
      }),
    ]
  }
  json.object([
    #(
      "serialization_options",
      json.object(
        []
        |> list.append(max_dom_depth)
        |> list.append(max_object_depth)
        |> list.append(include_shadow_tree),
      ),
    ),
  ])
}

pub type IncludeShadowTree {
  IncludeShadowTreeNone
  IncludeShadowTreeOpen
  IncludeShadowTreeAll
}

fn include_shadow_tree_to_json(include_shadow_tree: IncludeShadowTree) -> Json {
  case include_shadow_tree {
    IncludeShadowTreeNone -> json.string("none")
    IncludeShadowTreeOpen -> json.string("open")
    IncludeShadowTreeAll -> json.string("all")
  }
}
