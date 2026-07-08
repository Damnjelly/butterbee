# Butterbee Changelog

## [2.0.0] - 2026-07-08

- version bump

## [2.0.0] - 2025-11-22

### Added

- Added support for running tests in multiple browsers
- The browser now more consistently closes after a test panics, preventing lingering browser processes
- Added a chromium browser to the github action runner example
- By default filters out the `WebSocket handshake failed` error message

### Changed

- Merged page modules (`element`, `list_element`, `table_element`, `select_element`) into a single module `element`
- Merged config modules into a single module `config`
- Merged `driver` module into `butterbee`
- renamed `driver.new` and `driver.with_config` to `butterbee.run` and `butterbee.run_with_config`
- `butterbee.run` is now a callback function that is called like so:

```gleam
pub fn my_test() {
  use driver <- butterbee.run([Firefox])
}
```

- Made `command` module internal
- Made `browser` module internal
- Made `driver.close` (now `butterbee.close`) internal

### Fixed

- Page module's explanation page now responds to the theme toggle
- Tons of small documentation fixes

### Removed

- Removed all `@target` annotations
- Removed unused dependencies

## [1.0.0] - 2025-11-11

- Initial release




# Butterbidi Changelog

## [1.0.2] - 2026-07-08

- Version bump

## [1.0.1] - 2025-11-11

### Changed

- Moved to `palabres` for logging
- All `Uuid`'s are now `String`'s to be compatible with chromium

### Removed

- Removed `userAgent` from Capabilities as per the updated w3c spec
- Removed uuid decoder as it is no longer needed

### Fixed

- `capabilities_request_decoder` now properly decodes the data
- `capability_request_decoder` now properly decodes the data

## [1.0.0] - 2025-10-28

- Initial release
