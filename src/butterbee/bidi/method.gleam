pub type Method {
  // SESSION
  New
  // BROWSING CONTEXT
  GetTree
  LocateNodes
  Navigate
  // INPUT 
  PerformActions
}

pub fn to_string(command: Method) -> String {
  case command {
    // SESSION
    New -> "session.new"
    // BROWSING CONTEXT
    GetTree -> "browsingContext.getTree"
    LocateNodes -> "browsingContext.locateNodes"
    Navigate -> "browsingContext.navigate"
    // INPUT 
    PerformActions -> "input.performActions"
  }
}
