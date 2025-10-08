import butterbidi/browsing_context/commands/get_tree
import butterbidi/browsing_context/commands/locate_nodes
import butterbidi/browsing_context/commands/navigate
import gleam/dynamic/decode.{type Decoder}
import gleam/json.{type Json}

pub type BrowsingContextCommand {
  GetTree
  LocateNodes
  Navigate
}

pub fn browsing_context_command_to_json(command: BrowsingContextCommand) -> Json {
  json.string(browsing_context_command_to_string(command))
}

pub fn browsing_context_command_to_string(
  command: BrowsingContextCommand,
) -> String {
  case command {
    GetTree -> "browsingContext.getTree"
    LocateNodes -> "browsingContext.locateNodes"
    Navigate -> "browsingContext.navigate"
  }
}

pub type BrowsingContextResult {
  GetTreeResult(get_tree_result: get_tree.GetTreeResult)
  LocateNodesResult(locate_nodes_result: locate_nodes.LocateNodesResult)
  NavigateResult(navigate_result: navigate.NavigateResult)
}

pub fn browsing_context_result_decoder(
  command: BrowsingContextCommand,
) -> Decoder(BrowsingContextResult) {
  case command {
    GetTree -> {
      use get_tree_result <- decode.then(get_tree.get_tree_result_decoder())
      decode.success(GetTreeResult(get_tree_result: get_tree_result))
    }
    LocateNodes -> {
      use locate_nodes_result <- decode.then(
        locate_nodes.locate_nodes_result_decoder(),
      )
      decode.success(LocateNodesResult(locate_nodes_result: locate_nodes_result))
    }
    Navigate -> {
      use navigate_result <- decode.then(navigate.navigate_result_decoder())
      decode.success(NavigateResult(navigate_result: navigate_result))
    }
  }
}
