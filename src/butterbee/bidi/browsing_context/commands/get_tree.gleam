import butterbee/bidi/browsing_context/types/browsing_context.{
  type BrowsingContext,
}
import butterbee/bidi/browsing_context/types/info
import gleam/dynamic/decode
import gleam/json.{type Json}
import gleam/option.{type Option, None, Some}

pub type GetTreeParameters {
  GetTreeParameters(max_depth: Option(Int), root: Option(BrowsingContext))
}

pub fn get_tree_parameters_to_json(
  get_tree_parameters: GetTreeParameters,
) -> Json {
  let GetTreeParameters(max_depth:, root:) = get_tree_parameters
  json.object([
    #("max_depth", case max_depth {
      None -> json.null()
      Some(value) -> json.int(value)
    }),
    #("root", case root {
      None -> json.null()
      Some(value) -> todo as "Encoder for BrowsingContext"
    }),
  ])
}

pub fn default() -> GetTreeParameters {
  GetTreeParameters(None, None)
}

pub fn with_max_depth(
  get_tree_parameters: GetTreeParameters,
  max_depth: Int,
) -> GetTreeParameters {
  GetTreeParameters(..get_tree_parameters, max_depth: Some(max_depth))
}

pub fn with_root(
  get_tree_parameters: GetTreeParameters,
  root: BrowsingContext,
) -> GetTreeParameters {
  GetTreeParameters(..get_tree_parameters, root: Some(root))
}

pub type GetTreeResult {
  GetTreeResult(contexts: info.InfoList)
}

pub fn get_tree_result_decoder() -> decode.Decoder(GetTreeResult) {
  use contexts <- decode.field("contexts", info.info_list_decoder())
  decode.success(GetTreeResult(contexts:))
}
