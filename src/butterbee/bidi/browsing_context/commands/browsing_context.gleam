import butterbee/bidi/browsing_context/types/browsing_context.{
  type BrowsingContext, browsing_context_decoder,
}
import butterbee/bidi/browsing_context/types/locator.{type Locator}
import butterbee/bidi/browsing_context/types/readiness_state.{
  type ReadinessState,
}
import butterbee/bidi/method.{GetTree, LocateNodes, Navigate}
import butterbee/bidi/script/types/remote_value
import butterbee/bidi/script/types/serialization_options.{
  type SerializationOptions,
}
import butterbee/internal/socket
import gleam/dynamic/decode
import gleam/json.{type Json}
import gleam/list
import gleam/option.{type Option, None, Some}
import youid/uuid

///
/// # [browsingContext.getTree](https://w3c.github.io/webdriver-bidi/#command-browsingContext-getTree)
///
/// Returns a tree of all descendent navigables including the given 
/// parent itself, or all top-level contexts when no parent is provided.
/// 
/// ## Example
///
/// ```gleam
/// let browsing_tree =
///   browsing_context.get_tree(
///     session.0,
///     browsing_context.GetTreeParameters(None, None),
///   )
/// ```
///
pub fn get_tree(
  socket: socket.WebDriverSocket,
  params: GetTreeParameters,
) -> GetTreeResult {
  let request =
    socket.bidi_request(
      method.to_string(GetTree),
      get_tree_parameters_to_json(params),
    )

  let assert Ok(result) =
    socket.send_request(socket, request)
    |> decode.run(get_tree_result_decoder())

  result
}

pub type GetTreeParameters {
  GetTreeParameters(max_depth: Option(Int), root: Option(BrowsingContext))
}

fn get_tree_parameters_to_json(get_tree_parameters: GetTreeParameters) -> Json {
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

pub type GetTreeResult {
  GetTreeResult(contexts: List(BrowsingContext))
}

fn get_tree_result_decoder() -> decode.Decoder(GetTreeResult) {
  use contexts <- decode.field(
    "contexts",
    decode.list(browsing_context_decoder()),
  )
  decode.success(GetTreeResult(contexts:))
}

///
/// # [browsingContext.locateNodes](https://w3c.github.io/webdriver-bidi/#command-browsingContext-locateNodes)
///
/// Returns a list of all nodes matching the specified locator.
/// 
/// ## Example
///
/// ```gleam
/// let driver_with_nodes =
///   browsing_context.locate_nodes(
///     driver.socket,
///     browsing_context.LocateNodesParameters(
///       driver.context,
///       by.locator,
///       None,
///       None,
///     ),
///   )
///
/// let nodes =
///   { driver_with_nodes.1 }.nodes
///   |> list.map(fn(node) { Node(node) })
/// ```
///
pub fn locate_nodes(
  socket: socket.WebDriverSocket,
  params: LocateNodesParameters,
) -> #(socket.WebDriverSocket, LocateNodesResult) {
  let request =
    socket.bidi_request(
      method.to_string(LocateNodes),
      locate_nodes_parameters_to_json(params),
    )

  let assert Ok(result) =
    socket.send_request(socket, request)
    |> decode.run(locate_nodes_result_decoder())

  #(socket, result)
}

pub type LocateNodesParameters {
  LocateNodesParameters(
    context: BrowsingContext,
    locator: Locator,
    max_node_count: Option(Int),
    serialization_options: Option(SerializationOptions),
    //TODO: start_nodees: Option(script.SharedReference),
  )
}

fn locate_nodes_parameters_to_json(
  locate_nodes_parameters: LocateNodesParameters,
) -> Json {
  let LocateNodesParameters(
    context:,
    locator:,
    max_node_count:,
    serialization_options:,
  ) = locate_nodes_parameters
  json.object([
    #("context", json.string(uuid.to_string(context.context))),
    #("locator", locator.locator_to_json(locator)),
    #("max_node_count", case max_node_count {
      None -> json.null()
      Some(value) -> json.int(value)
    }),
    #("serialization_options", case serialization_options {
      None -> json.null()
      Some(value) -> serialization_options.serialization_options_to_json(value)
    }),
  ])
}

pub type LocateNodesResult {
  LocateNodesResult(nodes: List(remote_value.NodeRemoteValue))
}

fn locate_nodes_result_decoder() -> decode.Decoder(LocateNodesResult) {
  use nodes <- decode.field(
    "nodes",
    decode.list(remote_value.node_remote_value_decoder()),
  )
  decode.success(LocateNodesResult(nodes:))
}

///
/// # [browsingContext.navigate](https://w3c.github.io/webdriver-bidi/#command-browsingContext-navigate)
///
/// Navigates a navigable to the given URL.
/// 
/// ## Example
///
/// ```gleam
/// let driver =
///   browsing_context.navigate(
///     driver.socket,
///     browsing_context.NavigateParameters(
///       context: driver.context,
///       url: url,
///       wait: Some(readiness_state.Interactive),
///     ),
///   )
/// ```
///
pub fn navigate(
  socket: socket.WebDriverSocket,
  params: NavigateParameters,
) -> #(socket.WebDriverSocket, BrowsingContext) {
  let wait = case params.wait {
    None -> []
    Some(state) -> [
      #(
        "wait",
        json.nullable(
          Some(readiness_state.readiness_state_to_string(state)),
          json.string,
        ),
      ),
    ]
  }

  let request =
    socket.bidi_request(
      method.to_string(Navigate),
      navigate_parameters_to_json(params),
    )

  let assert Ok(result) =
    socket.send_request(socket, request)
    |> decode.run(navigate_result_decoder())

  #(socket, browsing_context.BrowsingContext(..params.context, url: result.url))
}

pub type NavigateParameters {
  NavigateParameters(
    context: BrowsingContext,
    url: String,
    wait: Option(ReadinessState),
  )
}

fn navigate_parameters_to_json(navigate_parameters: NavigateParameters) -> Json {
  let NavigateParameters(context:, url:, wait:) = navigate_parameters

  let wait = case wait {
    None -> []
    Some(state) -> [
      #(
        "wait",
        json.nullable(
          Some(readiness_state.readiness_state_to_string(state)),
          json.string,
        ),
      ),
    ]
  }

  json.object(
    [
      #("context", json.string(uuid.to_string(context.context))),
      #("url", json.string(url)),
    ]
    |> list.append(wait),
  )
}

pub type NavigateResult {
  NavigateResult(
    //navigation: Option(Navigation),
    url: String,
  )
}

fn navigate_result_decoder() -> decode.Decoder(NavigateResult) {
  use url <- decode.field("url", decode.string)
  decode.success(NavigateResult(url:))
}
