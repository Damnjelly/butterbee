pub type Method {
  // SESSION
  New
  End
  // BROWSING CONTEXT
  GetTree
  LocateNodes
  Navigate
  // SCRIPT
  CallFunction
  // INPUT 
  PerformActions
}

pub fn to_string(command: Method) -> String {
  case command {
    // SESSION
    New -> "session.new"
    End -> "session.end"
    // BROWSING CONTEXT
    GetTree -> "browsingContext.getTree"
    LocateNodes -> "browsingContext.locateNodes"
    Navigate -> "browsingContext.navigate"
    // SCRIPT
    CallFunction -> "script.callFunction"
    // INPUT 
    PerformActions -> "input.performActions"
  }
}
