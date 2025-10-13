import butterbee/internal/error
import butterbee/internal/lib
import butterlib/log
import gleam/dynamic.{type Dynamic}
import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/string
import simplifile

const default_flags = [
  "about:blank", "-wait-for-browser", "-no-first-run",
  "-no-default-browser-check", "-no-remote", "-new-instance", "-juggler-pipe",
]

///
/// Returns the flags firefox needs to run
///
pub fn get_flags(
  flags: List(String),
  port: Option(Int),
  profile_dir: String,
) -> List(String) {
  let remote_debugging_port = case port {
    None -> []
    Some(port) -> ["-remote-debugging-port=" <> int.to_string(port)]
  }
  default_flags
  |> list.append(remote_debugging_port)
  |> list.append(["-profile", profile_dir])
  |> list.append(flags)
}

///
/// Fill the profile directory with user prefs that provide a test environment
///
pub fn setup(profile_dir: String) -> Result(Nil, error.ButterbeeError) {
  log.debug("Creating user prefs")
  use _ <- result.try({
    write_user_prefs(profile_dir, [])
    |> result.map_error(fn(err) { error.CreateUserPrefsError(err) })
  })

  Ok(Nil)
}

type FirefoxPrefs {
  FirefoxPrefs(list: List(#(String, Dynamic)))
}

fn with_prefs(
  firefox: FirefoxPrefs,
  prefs: List(#(String, Dynamic)),
) -> FirefoxPrefs {
  FirefoxPrefs(firefox.list |> list.append(prefs))
}

fn default_prefs() -> FirefoxPrefs {
  let default_prefs = [
    // Make sure Shield doesn't hit the network.
    #("app.normandy.api_url", dynamic.string("\"\"")),
    // Disable Firefox old build background check
    #("app.update.checkInstallTime", dynamic.bool(False)),
    // Disable automatically upgrading Firefox
    #("app.update.disabledForTesting", dynamic.bool(True)),
    // Increase the APZ content response timeout to 1 minute
    #("app.content_response_timeout", dynamic.int(60_000)),
    // Prevent various error message on the console
    // jest-puppeteer asserts that no error message is emitted by the console
    #(
      "browser.contentblocking.features.standard",
      dynamic.string("'-tp,tpPrivate,cookieBehavior0,-cm,-fp'"),
    ),
    // Enable the dump function: which sends messages to the system
    // console
    // https://bugzilla.mozilla.org/show_bug.cgi?id=1543115
    #("browser.dom.window.dump.enabled", dynamic.bool(True)),
    // Make sure newtab weather doesn't hit the network to retrieve weather data.
    #(
      "browser.newtabpage.activity-stream.discoverystream.region-weather-config",
      dynamic.string(""),
    ),
    // Make sure newtab wallpapers don't hit the network to retrieve wallpaper data.
    #(
      "browser.newtabpage.activity-stream.newtabWallpapers.enabled",
      dynamic.bool(False),
    ),
    #(
      "browser.newtabpage.activity-stream.newtabWallpapers.v2.enabled",
      dynamic.bool(False),
    ),
    // Make sure Topsites doesn't hit the network to retrieve sponsored tiles.
    #(
      "browser.newtabpage.activity-stream.showSponsoredTopSites",
      dynamic.bool(False),
    ),
    // Disable topstories
    #(
      "browser.newtabpage.activity-stream.feeds.system.topstories",
      dynamic.bool(False),
    ),
    // Always display a blank page
    #("browser.newtabpage.enabled", dynamic.bool(False)),
    // Background thumbnails in particular cause grief: and disabling
    // thumbnails in general cannot hurt
    #("browser.pagethumbnails.capturing_disabled", dynamic.bool(True)),
    // Disable safebrowsing components.
    #("browser.safebrowsing.blockedURIs.enabled", dynamic.bool(False)),
    #("browser.safebrowsing.downloads.enabled", dynamic.bool(False)),
    #("browser.safebrowsing.malware.enabled", dynamic.bool(False)),
    #("browser.safebrowsing.phishing.enabled", dynamic.bool(False)),
    // Disable updates to search engines.
    #("browser.search.update", dynamic.bool(False)),
    // Do not restore the last open set of tabs if the browser has crashed
    #("browser.sessionstore.resume_from_crash", dynamic.bool(False)),
    // Skip check for default browser on startup
    #("browser.shell.checkDefaultBrowser", dynamic.bool(False)),
    // Disable newtabpage
    #("browser.startup.homepage", dynamic.string("about:blank")),
    // Do not redirect user when a milstone upgrade of Firefox is detected
    #("browser.startup.homepage_override.mstone", dynamic.string("ignore")),
    // Start with a blank page about:blank
    #("browser.startup.page", dynamic.int(0)),
    // Do not allow background tabs to be zombified on Android: otherwise for
    // tests that open additional tabs: the test harness tab itself might get
    // unloaded
    #("browser.tabs.disableBackgroundZombification", dynamic.bool(False)),
    // Do not warn when closing all other open tabs
    #("browser.tabs.warnOnCloseOtherTabs", dynamic.bool(False)),
    // Do not warn when multiple tabs will be opened
    #("browser.tabs.warnOnOpen", dynamic.bool(False)),
    // Do not automatically offer translations, as tests do not expect this.
    #("browser.translations.automaticallyPopup", dynamic.bool(False)),
    // Disable the UI tour.
    #("browser.uitour.enabled", dynamic.bool(False)),
    // Turn off search suggestions in the location bar so as not to trigger
    // network connections.
    #("browser.urlbar.suggest.searches", dynamic.bool(False)),
    // Disable first run splash page on Windows 10
    #("browser.usedOnWindows10.introURL", dynamic.string("\"\"")),
    // Do not warn on quitting Firefox
    #("browser.warnOnQuit", dynamic.bool(False)),
    // Defensively disable data reporting systems
    #(
      "datareporting.healthreport.documentServerURI",
      dynamic.string("'http://${server}/dummy/healthreport/'"),
    ),
    #("datareporting.healthreport.logging.consoleEnabled", dynamic.bool(False)),
    #("datareporting.healthreport.service.enabled", dynamic.bool(False)),
    #("datareporting.healthreport.service.firstRun", dynamic.bool(False)),
    #("datareporting.healthreport.uploadEnabled", dynamic.bool(False)),
    // Do not show datareporting policy notifications which can interfere with tests
    #("datareporting.policy.dataSubmissionEnabled", dynamic.bool(False)),
    #(
      "datareporting.policy.dataSubmissionPolicyBypassNotification",
      dynamic.bool(True),
    ),
    // DevTools JSONViewer sometimes fails to load dependencies with its require.js.
    // This doesn't affect Puppeteer but spams console (Bug 1424372)
    #("devtools.jsonview.enabled", dynamic.bool(False)),
    // Disable popup-blocker
    #("dom.disable_open_during_load", dynamic.bool(False)),
    // Enable the support for File object creation in the content process
    // Required for |Page.setFileInputFiles| protocol method.
    #("dom.file.createInChild", dynamic.bool(True)),
    // Disable the ProcessHangMonitor
    #("dom.ipc.reportProcessHangs", dynamic.bool(False)),
    // Disable slow script dialogues
    #("dom.max_chrome_script_run_time", dynamic.int(0)),
    #("dom.max_script_run_time", dynamic.int(0)),
    // Disable background timer throttling to allow tests to run in parallel
    // without a decrease in performance.
    #("dom.min_background_timeout_value", dynamic.int(0)),
    #(
      "dom.min_background_timeout_value_without_budget_throttling",
      dynamic.int(0),
    ),
    #("dom.timeout.enable_budget_timer_throttling", dynamic.bool(False)),
    // Disable HTTPS-First upgrades
    #("dom.security.https_first", dynamic.bool(False)),
    // Only load extensions from the application and user profile
    // AddonManager.SCOPE_PROFILE + AddonManager.SCOPE_APPLICATION
    #("extensions.autoDisableScopes", dynamic.int(0)),
    #("extensions.enabledScopes", dynamic.int(5)),
    // Disable metadata caching for installed add-ons by default
    #("extensions.getAddons.cache.enabled", dynamic.bool(False)),
    // Disable installing any distribution extensions or add-ons.
    #("extensions.installDistroAddons", dynamic.bool(False)),
    // Disabled screenshots extension
    #("extensions.screenshots.disabled", dynamic.bool(True)),
    // Turn off extension updates so they do not bother tests
    #("extensions.update.enabled", dynamic.bool(False)),
    // Turn off extension updates so they do not bother tests
    #("extensions.update.notifyUser", dynamic.bool(False)),
    // Make sure opening about:addons will not hit the network
    #(
      "extensions.webservice.discoverURL",
      dynamic.string("'http://${server}/dummy/discoveryURL'"),
    ),
    // Allow the application to have focus even it runs in the background
    #("focusmanager.testmode", dynamic.bool(True)),
    // Disable useragent updates
    #("general.useragent.updates.enabled", dynamic.bool(False)),
    // Always use network provider for geolocation tests so we bypass the
    // macOS dialog raised by the corelocation provider
    #("geo.provider.testing", dynamic.bool(True)),
    // Do not scan Wifi
    #("geo.wifi.scan", dynamic.bool(False)),
    // No hang monitor
    #("hangmonitor.timeout", dynamic.int(0)),
    // Show chrome errors and warnings in the error console
    #("javascript.options.showInConsole", dynamic.bool(True)),
    // Do not throttle rendering (requestAnimationFrame) in background tabs
    #("layout.testing.top-level-always-active", dynamic.bool(True)),
    // Disable download and usage of OpenH264: and Widevine plugins
    #("media.gmp-manager.updateEnabled", dynamic.bool(False)),
    // Disable the GFX sanity window
    #("media.sanity-test.disabled", dynamic.bool(True)),
    // Disable connectivity service pings
    #("network.connectivity-service.enabled", dynamic.bool(False)),
    // Disable experimental feature that is only available in Nightly
    #("network.cookie.sameSite.laxByDefault", dynamic.bool(False)),
    // Do not prompt for temporary redirects
    #("network.http.prompt-temp-redirect", dynamic.bool(False)),
    // Disable speculative connections so they are not reported as leaking
    // when they are hanging around
    #("network.http.speculative-parallel-limit", dynamic.int(0)),
    // Do not automatically switch between offline and online
    #("network.manage-offline-status", dynamic.bool(False)),
    // Make sure SNTP requests do not hit the network
    #("network.sntp.pools", dynamic.string("server")),
    // Disable Flash.
    #("plugin.state.flash", dynamic.int(0)),
    #("privacy.trackingprotection.enabled", dynamic.bool(False)),
    // Can be removed once Firefox 89 is no longer supported
    // https://bugzilla.mozilla.org/show_bug.cgi?id=1710839
    #("remote.enabled", dynamic.bool(True)),
    // Don't do network connections for mitm priming
    #("security.certerrors.mitm.priming.enabled", dynamic.bool(False)),
    // Local documents have access to all other local documents)
    // including directory listings
    #("security.fileuri.strict_origin_policy", dynamic.bool(False)),
    // Do not wait for the notification button security delay
    #("security.notification_enable_delay", dynamic.int(0)),
    // Do not automatically fill sign-in forms with known usernames and
    // passwords
    #("signon.autofillForms", dynamic.bool(False)),
    // Disable password capture, so that tests that include forms are not
    // influenced by the presence of the persistent doorhanger notification
    #("signon.rememberSignons", dynamic.bool(False)),
    // Disable first-run welcome page
    #("startup.homepage_welcome_url", dynamic.string("about:blank")),
    // Disable first-run welcome page
    #("startup.homepage_welcome_url.additional", dynamic.string("")),
    // Disable browser animations (tabs, fullscreen, sliding alerts)
    #("toolkit.cosmeticAnimations.enabled", dynamic.bool(False)),
    // Disable user stylesheets
    #(
      "toolkit.legacyUserProfileCustomizations.stylesheets",
      dynamic.bool(False),
    ),
    // Prevent starting into safe mode after application crashes
    #("toolkit.startup.max_resumed_crashes", dynamic.int(-1)),
  ]

  FirefoxPrefs(default_prefs)
}

fn write_user_prefs(profile_dir: String, config_prefs: List(#(String, Dynamic))) {
  let user_prefs =
    default_prefs()
    |> with_prefs(config_prefs)
    |> prefs_to_js()

  let filepath = profile_dir <> "/user.js"

  simplifile.write(filepath, user_prefs)
}

/// Escapes special characters in strings for JavaScript
/// Converts a single preference tuple to a prefs.js line
fn pref_to_line(pref: #(String, Dynamic)) -> String {
  let #(key, value) = pref
  "user_pref(\"" <> key <> "\", " <> lib.dynamic_to_string(value) <> ");"
}

/// Converts a list of Firefox preference tuples to a prefs.js file content string
fn prefs_to_js(firefox: FirefoxPrefs) -> String {
  firefox.list
  |> list.map(pref_to_line)
  |> string.join("\n")
  |> string.append("\n")
}
