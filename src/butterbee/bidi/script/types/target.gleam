import butterbee/bidi/browsing_context/types/browsing_context
import gleam/json.{type Json}
import gleam/list
import gleam/option.{type Option, None, Some}
import youid/uuid

pub type Target {
  Context(ContextTarget)
  //TODO: Realm(RealmTarget)
}

pub fn target_to_json(target: Target) -> Json {
  case target {
    Context(context_target) -> context_target_to_json(context_target)
    //TODO: Realm(realm_target) -> realm_target_to_json(realm_target)
  }
}

// TODO: pub type RealmTarget {
//   RealmTarget(realm: Realm)
// }

pub type ContextTarget {
  ContextTarget(
    context: browsing_context.BrowsingContext,
    sandbox: Option(String),
  )
}

pub fn new_context_target(context: browsing_context.BrowsingContext) -> Target {
  Context(ContextTarget(context, None))
}

pub fn with_sandbox(context_target: ContextTarget, sandbox: String) -> Target {
  Context(ContextTarget(..context_target, sandbox: Some(sandbox)))
}

pub fn context_target_to_json(context_target: ContextTarget) -> Json {
  let ContextTarget(context:, sandbox:) = context_target
  let sandbox = case sandbox {
    None -> []
    Some(value) -> [#("sandbox", json.string(value))]
  }
  json.object(
    [#("context", json.string(uuid.to_string(context.id)))]
    |> list.append(sandbox),
  )
}
