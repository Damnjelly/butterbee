import butterbee/bidi/browsing_context/types/browsing_context.{
  type BrowsingContext,
}
import butterbee/bidi/browsing_context/types/readiness_state.{
  type ReadinessState,
}
import gleam/dynamic/decode
import gleam/json.{type Json}
import gleam/list
import gleam/option.{type Option, None, Some}
import youid/uuid

pub type NavigateParameters {
  NavigateParameters(
    context: BrowsingContext,
    url: String,
    wait: Option(ReadinessState),
  )
}

pub fn navigate_parameters_to_json(
  navigate_parameters: NavigateParameters,
) -> Json {
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
      #("context", json.string(uuid.to_string(context.id))),
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

pub fn navigate_result_decoder() -> decode.Decoder(NavigateResult) {
  use url <- decode.field("url", decode.string)
  decode.success(NavigateResult(url:))
}
