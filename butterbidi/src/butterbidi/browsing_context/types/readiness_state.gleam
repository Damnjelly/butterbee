pub type ReadinessState {
  /// "None" is a reserved keyword in Gleam, so we use "Nothing" instead
  Nothing
  Complete
  Interactive
}

pub fn readiness_state_to_string(state: ReadinessState) -> String {
  case state {
    Nothing -> "none"
    Complete -> "complete"
    Interactive -> "interactive"
  }
}
