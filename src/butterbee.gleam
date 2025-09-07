import butterbee/bidi/browsing_context/commands/get_tree
import butterbee/bidi/browsing_context/types/info
import butterbee/bidi/definition
import gleam/erlang/process
import gleam/http/request
import gleam/json
import logging
import simplifile
import stratus

pub fn init() {
  logging.log(logging.Debug, "Initializing butterbee")

  logging.log(logging.Debug, "Deleteing data_dir")
  simplifile.delete("/tmp/butterbee")
}

const get_treee = "{
  id: 1757269990460208,
  result: {
    contexts: [
      {
        children: [  ],
        clientWindow: \"2795b6e9-de94-4112-bbc5-7a3115f0eb4f\",
        context: \"39266702-f679-4505-a6f4-dc91c07f4bb8\",
        originalOpener: null,
        parent: null,
        url: \"about:home\",
        userContext: \"default\"
      }
    ]
  },
  type: \"success\"
}"

fn test_json() -> String {
  json.object([
    #("children", json.array([], json.object)),
    #("clientWindow", json.string("2795b6e9-de94-4112-bbc5-7a3115f0eb4f")),
    #("context", json.string("39266702-f679-4505-a6f4-dc91c07f4bb8")),
    #("originalOpener", json.null()),
    #("parent", json.null()),
    #("url", json.string("about:home")),
    #("userContext", json.string("default")),
  ])
  |> json.to_string()
}

pub fn main() {
  echo json.parse(test_json(), info.info_decoder())
}
