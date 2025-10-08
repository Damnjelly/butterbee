import butterbidi/browsing_context/types/browsing_context.{type BrowsingContext}
import butterbidi/input/types/element_origin
import butterbidi/script/types/remote_reference
import gleam/json.{type Json}
import gleam/list
import gleam/option.{type Option, None, Some}
import youid/uuid

pub type PerformActionsParameters {
  PerformActionsParameters(
    context: BrowsingContext,
    actions: List(SourceActions),
  )
}

pub fn perform_actions_parameters_to_json(
  perform_actions_parameters: PerformActionsParameters,
) -> Json {
  let PerformActionsParameters(context:, actions:) = perform_actions_parameters
  json.object([
    #("context", json.string(uuid.to_string(context.id))),
    #("actions", json.array(actions, source_actions_to_json)),
  ])
}

pub fn default(context: BrowsingContext) -> PerformActionsParameters {
  PerformActionsParameters(context, [])
}

pub fn with_actions(
  perform_actions_parameters: PerformActionsParameters,
  actions: List(SourceActions),
) -> PerformActionsParameters {
  PerformActionsParameters(..perform_actions_parameters, actions: actions)
}

pub type SourceActions {
  //TODO: NoneSource(NoneSourceActions)
  KeySource(KeySourceActions)
  PointerSource(PointerSourceActions)
  //TODO: WheelSource(WheelSourceActions)
}

fn source_actions_to_json(source_actions: SourceActions) -> Json {
  case source_actions {
    //TODO: NoneSource(none_source_action) -> todo
    KeySource(key_source_actions) ->
      key_source_actions_to_json(key_source_actions)
    PointerSource(pointer_source_actions) ->
      pointer_source_actions_to_json(pointer_source_actions)
    //TODO: WheelSource(wheel_source_action) -> todo
  }
}

pub fn key_actions(id: String, actions: List(KeySourceAction)) -> SourceActions {
  KeySource(KeySourceActions(id, actions))
}

pub fn pointer_actions(
  id: String,
  actions: List(PointerSourceAction),
) -> SourceActions {
  PointerSource(PointerSourceActions(id, None, actions))
}

pub fn with_parameters(
  source_actions: SourceActions,
  parameters: PointerParameters,
) -> SourceActions {
  case source_actions {
    PointerSource(pointer_source_actions) ->
      PointerSource(
        PointerSourceActions(
          ..pointer_source_actions,
          parameters: Some(parameters),
        ),
      )
    _ -> panic as "#Expected pointer source actions"
  }
}

pub fn with_pointer_actions(
  source_actions: SourceActions,
  actions: List(PointerSourceAction),
) -> SourceActions {
  case source_actions {
    PointerSource(pointer_source_actions) ->
      PointerSource(
        PointerSourceActions(..pointer_source_actions, actions: actions),
      )
    _ -> panic as "#Expected pointer source actions"
  }
}

pub type KeySourceActions {
  KeySourceActions(id: String, actions: List(KeySourceAction))
}

fn key_source_actions_to_json(key_source_actions: KeySourceActions) -> Json {
  let KeySourceActions(id:, actions:) = key_source_actions
  json.object([
    #("type", json.string("key")),
    #("id", json.string(id)),
    #("actions", json.array(actions, key_source_action_to_json)),
  ])
}

pub type KeySourceAction {
  KeyDown(KeyDownAction)
  KeyUp(KeyUpAction)
}

fn key_source_action_to_json(key_source_action: KeySourceAction) -> Json {
  case key_source_action {
    KeyDown(key_down_action) -> key_down_action_to_json(key_down_action)
    KeyUp(key_up_action) -> key_up_action_to_json(key_up_action)
  }
}

pub fn key_down_action(key: String) -> KeySourceAction {
  KeyDown(KeyDownAction(key))
}

pub fn key_up_action(key: String) -> KeySourceAction {
  KeyUp(KeyUpAction(key))
}

pub type PointerSourceActions {
  PointerSourceActions(
    id: String,
    parameters: Option(PointerParameters),
    actions: List(PointerSourceAction),
  )
}

fn pointer_source_actions_to_json(
  pointer_source_action: PointerSourceActions,
) -> Json {
  let PointerSourceActions(id:, parameters:, actions:) = pointer_source_action

  let parameters = case parameters {
    option.None -> []
    option.Some(value) -> [#("parameters", pointer_parameters_to_json(value))]
  }
  json.object(
    [
      #("type", json.string("pointer")),
      #("id", json.string(id)),
      #("actions", json.array(actions, pointer_source_action_to_json)),
    ]
    |> list.append(parameters),
  )
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

pub type PointerParameters {
  PointerParameters(pointer_type: Option(PointerType))
}

fn pointer_parameters_to_json(pointer_parameters: PointerParameters) -> Json {
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

pub type PointerSourceAction {
  //TODO: Pause(PointerPauseAction)
  PointerDown(PointerDownAction)
  PointerUp(PointerUpAction)
  PointerMove(PointerMoveAction)
}

pub fn pointer_down_action(button: Int) -> PointerSourceAction {
  PointerDown(PointerDownAction(button))
}

pub fn pointer_up_action(button: Int) -> PointerSourceAction {
  PointerUp(PointerUpAction(button))
}

pub fn pointer_move_action(
  x: Int,
  y: Int,
  duration: Option(Int),
  origin: Option(Origin),
) -> PointerSourceAction {
  PointerMove(PointerMoveAction(x, y, duration, origin))
}

fn pointer_source_action_to_json(
  pointer_source_action: PointerSourceAction,
) -> Json {
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

pub type KeyDownAction {
  KeyDownAction(value: String)
}

fn key_down_action_to_json(key_down_action: KeyDownAction) -> Json {
  let KeyDownAction(value:) = key_down_action
  json.object([
    #("type", json.string("keyDown")),
    #("value", json.string(value)),
  ])
}

pub type KeyUpAction {
  KeyUpAction(value: String)
}

fn key_up_action_to_json(key_up_action: KeyUpAction) -> Json {
  let KeyUpAction(value:) = key_up_action
  json.object([#("type", json.string("keyUp")), #("value", json.string(value))])
}

pub type PointerUpAction {
  PointerUpAction(
    button: Int,
    //TODO: common_properties: PointerCommonProperties
  )
}

fn pointer_up_action_to_json(pointer_up_action: PointerUpAction) -> Json {
  let PointerUpAction(button:) = pointer_up_action
  json.object([
    #("type", json.string("pointerUp")),
    #("button", json.int(button)),
  ])
}

pub type PointerDownAction {
  PointerDownAction(
    button: Int,
    //TODO: common_properties: PointerCommonProperties
  )
}

fn pointer_down_action_to_json(pointer_down_action: PointerDownAction) -> Json {
  let PointerDownAction(button:) = pointer_down_action
  json.object([
    #("type", json.string("pointerDown")),
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

fn pointer_move_action_to_json(pointer_move_action: PointerMoveAction) -> Json {
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
  Element(element_origin.ElementOrigin)
}

fn origin_to_json(origin: Origin) -> Json {
  case origin {
    Viewport -> json.string("viewport")
    Pointer -> json.string("pointer")
    Element(element_origin) ->
      element_origin.element_origin_to_json(element_origin)
  }
}

pub fn viewport_origin() -> Origin {
  Viewport
}

pub fn pointer_origin() -> Origin {
  Pointer
}

pub fn element_origin(
  shared_reference: remote_reference.SharedReference,
) -> Option(Origin) {
  Some(Element(element_origin.ElementOrigin(shared_reference)))
}
