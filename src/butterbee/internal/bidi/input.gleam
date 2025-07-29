////
//// ▗▄▄▄▖▗▖  ▗▖▄▄▄▄  █  ▐▌▗▄▄▄▖
////   █  ▐▛▚▖▐▌█   █ ▀▄▄▞▘  █  
////   █  ▐▌ ▝▜▌█▄▄▄▀        █  
//// ▗▄█▄▖▐▌  ▐▌█            █  
////            ▀               
////
//// The input module contains functionality for simulated user input.

import butterbee/internal/bidi/browsing_context
import butterbee/internal/bidi/script
import butterbee/internal/helper
import butterbee/internal/socket
import gleam/dynamic/decode
import gleam/json
import gleam/list
import gleam/option.{type Option}
import youid/uuid.{type Uuid}

pub type SourceActions {
  //TODO: NoneSourceActions(NoneSourceAction)
  PointerSource(PointerSourceActions)
  //TODO: KeySourceActions(KeySourceAction)
  //TODO: WheelSourceActions(WheelSourceAction)
}

fn source_actions_to_json(source_actions: SourceActions) -> json.Json {
  case source_actions {
    //TODO: NoneSourceActions(none_source_action) -> todo
    PointerSource(pointer_source_actions) ->
      pointer_source_actions_to_json(pointer_source_actions)
    //TODO: KeySourceActions(key_source_action) -> todo
    //TODO: WheelSourceActions(wheel_source_action) -> todo
  }
}

pub type PointerSourceActions {
  PointerSourceActions(
    id: Uuid,
    parameters: Option(PointerParameters),
    actions: List(PointerSourceAction),
  )
}

fn pointer_source_actions_to_json(
  pointer_source_action: PointerSourceActions,
) -> json.Json {
  let PointerSourceActions(id:, parameters:, actions:) = pointer_source_action

  let parameters = case parameters {
    option.None -> []
    option.Some(value) -> [#("parameters", pointer_parameters_to_json(value))]
  }
  json.object(
    [
      #("type", json.string("pointer")),
      #("id", json.string(uuid.to_string(id))),
      #("actions", json.array(actions, pointer_source_action_to_json)),
    ]
    |> list.append(parameters),
  )
}

pub type PointerSourceAction {
  //TODO: Pause(PointerPauseAction)
  PointerDown(PointerDownAction)
  PointerUp(PointerUpAction)
  PointerMove(PointerMoveAction)
}

fn pointer_source_action_to_json(
  pointer_source_action: PointerSourceAction,
) -> json.Json {
  case pointer_source_action {
    //TODO: Pause(pointer_pause_action) ->
    //   pointer_pause_action_to_json(pointer_pause_action)
    PointerDown(pointer_down_action) ->
      pointer_down_action_to_json(pointer_down_action)
    PointerUp(pointer_up_action) -> pointer_up_action_to_json(pointer_up_action)
    PointerMove(pointer_move_action) ->
      pointer_move_action_to_json(pointer_move_action)
  }
}

pub type PointerDownAction {
  PointerDownAction(
    button: Int,
    //TODO: common_properties: PointerCommonProperties
  )
}

fn pointer_down_action_to_json(
  pointer_down_action: PointerDownAction,
) -> json.Json {
  let PointerDownAction(button:) = pointer_down_action
  json.object([
    #("type", json.string("pointerDown")),
    #("button", json.int(button)),
  ])
}

pub type PointerUpAction {
  PointerUpAction(
    button: Int,
    //TODO: common_properties: PointerCommonProperties
  )
}

fn pointer_up_action_to_json(pointer_up_action: PointerUpAction) -> json.Json {
  let PointerUpAction(button:) = pointer_up_action
  json.object([
    #("type", json.string("pointerUp")),
    #("button", json.int(button)),
  ])
}

pub type PointerMoveAction {
  PointerMoveAction(
    x: Int,
    y: Int,
    duration: Option(Int),
    origin: Option(Origin),
    //TODO: common_properties: PointerCommonProperties
  )
}

fn pointer_move_action_to_json(
  pointer_move_action: PointerMoveAction,
) -> json.Json {
  let PointerMoveAction(x:, y:, duration:, origin:) = pointer_move_action
  let duration = case duration {
    option.None -> []
    option.Some(value) -> [#("duration", json.int(value))]
  }
  let origin = case origin {
    option.None -> []
    option.Some(value) -> [#("origin", origin_to_json(value))]
  }
  json.object(
    [
      #("type", json.string("pointerMove")),
      #("x", json.int(x)),
      #("y", json.int(y)),
    ]
    |> list.append(duration)
    |> list.append(origin),
  )
}

pub type Origin {
  Viewport
  Pointer
  Element(ElementOrigin)
}

fn origin_to_json(origin: Origin) -> json.Json {
  case origin {
    Viewport -> json.string("viewport")
    Pointer -> json.string("pointer")
    Element(element_origin) -> element_origin_to_json(element_origin)
  }
}

pub type ElementOrigin {
  ElementOrigin(element: script.SharedReference)
}

fn element_origin_to_json(element_origin: ElementOrigin) -> json.Json {
  let ElementOrigin(element:) = element_origin
  json.object([
    #("type", json.string("element")),
    #("element", script.shared_reference_to_json(element)),
  ])
}

pub type PointerParameters {
  PointerParameters(pointer_type: Option(PointerType))
}

fn pointer_parameters_to_json(
  pointer_parameters: PointerParameters,
) -> json.Json {
  let PointerParameters(pointer_type:) = pointer_parameters
  json.object([
    #(
      "pointerType",
      json.string(case pointer_type {
        option.None -> pointer_type_to_string(Mouse)
        option.Some(value) -> pointer_type_to_string(value)
      }),
    ),
  ])
}

pub type PointerType {
  Mouse
  Pen
  Touch
}

fn pointer_type_to_string(pointer_type: PointerType) -> String {
  case pointer_type {
    Mouse -> "mouse"
    Pen -> "pen"
    Touch -> "touch"
  }
}

type Methods {
  PerformActions
}

fn method_to_string(command: Methods) -> String {
  case command {
    PerformActions -> "input.performActions"
  }
}

/// Since this one is a bit more complicated, here is a minimal example of clicking on a button:
///
/// ```gleam
///  let testdriver = #(webdriver.socket, webdriver.context)
///  let testdriver =
///    browsing_context.locate_nodes(
///      testdriver,
///      browsing_context.XPathLocator("/html/body/div[1]/div/div/div[2]/div/a"),
///      None,
///      None,
///    )
///  
///  let webdriver = testdriver.0
///  let assert Ok(locator) = testdriver.1 |> list.first()
///  let assert Some(locator_id) = locator.shared_id
///  
///  input.perform_actions(#(webdriver.0, webdriver.1), [
///    input.PointerSource(
///      input.PointerSourceActions(uuid.nil, None, [
///        input.PointerMove(input.PointerMoveAction(
///          0,
///          0,
///          None,
///          Some(
///            input.Element(
///              input.ElementOrigin(script.SharedReference(locator_id, None)),
///            ),
///          ),
///        )),
///        input.PointerDown(input.PointerDownAction(0)),
///        input.PointerUp(input.PointerUpAction(0)),
///      ]),
///    ),
///  ])
/// ```
pub fn perform_actions(
  driver: #(socket.WebDriverSocket, browsing_context.BrowsingContext),
  actions: List(SourceActions),
) -> #(socket.WebDriverSocket, browsing_context.BrowsingContext) {
  let socket = driver.0
  let context = driver.1

  let request =
    socket.bidi_request(
      method_to_string(PerformActions),
      json.object([
        #("context", json.string(uuid.to_string(context.context))),
        #("actions", json.array(actions, source_actions_to_json)),
      ]),
    )

  echo socket.send_request(socket, request)

  driver
}
