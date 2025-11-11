# Butterbee Changelog

## [Unreleased]

## [1.0.0] - 2025-11-11

- Initial release

# Butterbidi Changelog

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
