////
//// ▗▄▄▖  ▄▄▄ ▄▄▄  ▄   ▄  ▄▄▄ ▄ ▄▄▄▄   ▗▄▄▖     ▗▄▄▖▄▄▄  ▄▄▄▄▗▄▄▄▖▗▞▀▚▖▄   ▄ ▗▄▄▄▖
//// ▐▌ ▐▌█   █   █ █ ▄ █ ▀▄▄  ▄ █   █ ▐▌       ▐▌  █   █ █   █ █  ▐▛▀▀▘ ▀▄▀    █  
//// ▐▛▀▚▖█   ▀▄▄▄▀ █▄█▄█ ▄▄▄▀ █ █   █ ▐▌▝▜▌    ▐▌  ▀▄▄▄▀ █   █ █  ▝▚▄▄▖▄▀ ▀▄   █  
//// ▐▙▄▞▘                     █       ▝▚▄▞▘    ▝▚▄▄▖           █               █  
////
//// The browsingContext module contains commands and events relating to navigables.
////                                                                                     
//// https://w3c.github.io/webdriver-bidi/#module-browsingContext

import butterbee/internal/bidi/script
import butterbee/internal/decoders
import butterbee/internal/socket
import gleam/dynamic/decode
import gleam/json
import gleam/list
import gleam/option.{type Option, None, Some}
import youid/uuid.{type Uuid}

pub type ReadinessState {
  /// "None" is a reserved keyword in Gleam, so we use "Nothing" instead
  Nothing
  Complete
  Interactive
}

fn readyness_state_to_string(state: ReadinessState) -> String {
  case state {
    Nothing -> "none"
    Complete -> "complete"
    Interactive -> "interactive"
  }
}

pub type MatchType {
  Full
  Partial
}

fn match_type_to_string(match_type: MatchType) -> String {
  case match_type {
    Full -> "full"
    Partial -> "partial"
  }
}

pub type Locator {
  AccessibilityLocator(name: Option(String), role: Option(String))
  CssLocator(value: String)
  ContextLocator(context: BrowsingContext)
  InnerTextLocator(
    value: String,
    ignore_case: Option(Bool),
    match_type: Option(MatchType),
    max_depth: Option(Int),
  )
  XPathLocator(value: String)
}

fn locator_to_json(locator: Locator) -> json.Json {
  case locator {
    AccessibilityLocator(name:, role:) ->
      json.object([
        #("type", json.string("accessibility")),
        #("name", case name {
          None -> json.null()
          Some(value) -> json.string(value)
        }),
        #("role", case role {
          None -> json.null()
          Some(value) -> json.string(value)
        }),
      ])
    CssLocator(value:) ->
      json.object([
        #("type", json.string("css")),
        #("value", json.string(value)),
      ])
    ContextLocator(context:) ->
      json.object([
        #("type", json.string("context")),
        #("context", todo as "Encoder for BrowsingContext"),
      ])
    InnerTextLocator(value:, ignore_case:, match_type:, max_depth:) ->
      json.object([
        #("type", json.string("innerText")),
        #("value", json.string(value)),
        #("ignore_case", case ignore_case {
          None -> json.null()
          Some(value) -> json.bool(value)
        }),
        #("match_type", case match_type {
          None -> json.null()
          Some(value) -> json.string(match_type_to_string(value))
        }),
        #("max_depth", case max_depth {
          None -> json.null()
          Some(value) -> json.int(value)
        }),
      ])
    XPathLocator(value:) ->
      json.object([
        #("type", json.string("xpath")),
        #("value", json.string(value)),
      ])
  }
}

pub type BrowsingContext {
  BrowsingContext(
    //TODO: children: List(BrowsingContext),
    //TODO: client_window: ClientWindow,
    context: Uuid,
    //TODO: original_opener: BrowsingContext,
    url: String,
    //TODO: user_context: UserContext,
    //TODO: parent: Option(BrowsingContext),
  )
}

fn browsing_context_decoder() -> decode.Decoder(BrowsingContext) {
  // WARN: This results into an infinite loop
  // use children <- decode.field(
  //   "children",
  //   decode.list(browsing_context_decoder()),
  // )
  use context <- decode.field("context", decoders.uuid())
  use url <- decode.field("url", decode.string)
  decode.success(BrowsingContext(context:, url:))
}

pub type Method {
  GetTree
  LocateNodes
  Navigate
}

fn method_to_string(command: Method) -> String {
  case command {
    GetTree -> "browsingContext.getTree"
    LocateNodes -> "browsingContext.locateNodes"
    Navigate -> "browsingContext.navigate"
  }
}

/// Returns a tree of all descendent navigables including the given 
/// parent itself, or all top-level contexts when no parent is provided.
pub fn get_tree(
  socket: socket.WebDriverSocket,
  max_depth: Option(Int),
  root: Option(BrowsingContext),
) -> List(BrowsingContext) {
  let root_context = case root {
    None -> None
    Some(context) -> Some(uuid.to_string(context.context))
  }

  let request =
    socket.bidi_request(
      method_to_string(GetTree),
      json.object([
        #("maxDepth", json.nullable(max_depth, json.int)),
        #("root", json.nullable(root_context, json.string)),
      ]),
    )

  let assert Ok(contexts) =
    socket.send_request(socket, request)
    |> decode.run({
      use context_list <- decode.field(
        "contexts",
        decode.list(browsing_context_decoder()),
      )
      decode.success(context_list)
    })

  contexts
}

/// Returns a list of all nodes matching the specified locator.
pub fn locate_nodes(
  driver: #(socket.WebDriverSocket, BrowsingContext),
  locator: Locator,
  max_node_count: Option(Int),
  serialization_options: Option(script.SerializationOptions),
  //TODO: start_nodees: Option(script.SharedReference),
) -> #(#(socket.WebDriverSocket, BrowsingContext), List(script.NodeRemoteValue)) {
  let socket = driver.0
  let context = driver.1

  let max_node_count = case max_node_count {
    None -> []
    Some(count) -> [#("maxNodeCount", json.nullable(Some(count), json.int))]
  }

  let serialization_options = case serialization_options {
    None -> []
    Some(options) -> script.serialization_options_to_json(options)
  }

  let request =
    socket.bidi_request(
      method_to_string(LocateNodes),
      json.object(
        [
          #("context", json.string(uuid.to_string(context.context))),
          #("locator", locator_to_json(locator)),
        ]
        |> list.append(max_node_count)
        |> list.append(serialization_options),
      ),
    )

  let assert Ok(nodes) =
    socket.send_request(socket, request)
    |> decode.run({
      use node_list <- decode.field(
        "nodes",
        decode.list(script.node_remote_value_decoder()),
      )
      decode.success(node_list)
    })

  #(driver, nodes)
}

/// Navigates a navigable to the given URL.
pub fn navigate(
  driver: #(socket.WebDriverSocket, BrowsingContext),
  url: String,
  wait: Option(ReadinessState),
) -> #(socket.WebDriverSocket, BrowsingContext) {
  let socket = driver.0
  let context = driver.1

  let wait = case wait {
    None -> []
    Some(state) -> [
      #(
        "wait",
        json.nullable(Some(readyness_state_to_string(state)), json.string),
      ),
    ]
  }

  let request =
    socket.bidi_request(
      method_to_string(Navigate),
      json.object(
        [
          #("context", json.string(uuid.to_string(context.context))),
          #("url", json.string(url)),
        ]
        |> list.append(wait),
      ),
    )

  let url_decoder = {
    use new_url <- decode.field("url", decode.string)
    decode.success(BrowsingContext(..context, url: new_url))
  }
  let assert Ok(context) =
    socket.send_request(socket, request)
    |> decode.run(url_decoder)

  #(socket, context)
}
