import butterbee/config/browser_config.{type BrowserType}

pub type Runnable {
  Firefox(
    cmd: #(String, List(String)),
    port: String,
    profile: String,
    profile_dir: String,
  )
}

pub fn new(browser_type: BrowserType) -> Runnable {
  case browser_type {
    browser_config.Firefox ->
      Firefox(cmd: #("", []), port: "", profile: "", profile_dir: "")
    browser_config.Chrome -> todo as "chrome is not supported yet"
  }
}

pub fn with_cmd(runnable: Runnable, cmd: #(String, List(String))) -> Runnable {
  case runnable {
    Firefox(..) -> Firefox(..runnable, cmd: cmd)
  }
}

pub fn with_port(runnable: Runnable, port: String) -> Runnable {
  case runnable {
    Firefox(..) -> Firefox(..runnable, port: port)
  }
}

pub fn with_profile(runnable: Runnable, profile: String) -> Runnable {
  case runnable {
    Firefox(..) -> Firefox(..runnable, profile: profile)
  }
}

pub fn with_profile_dir(runnable: Runnable, profile_dir: String) -> Runnable {
  case runnable {
    Firefox(..) -> Firefox(..runnable, profile_dir: profile_dir)
  }
}
