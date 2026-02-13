# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.19.0] - 2025-02-11

### Compatibility

- **Ruby**: Gemspec now sets `required_ruby_version = '>= 3.0'`. Ruby 2.x is no longer supported.
- **string_pattern**: Runtime dependency is `~> 2.4` (was `~> 2.3`). Upgrade to string_pattern 2.4+ when upgrading to nice_hash 1.19.
- **:uuid**: The symbol `:uuid` as a pattern value now generates/validates a UUID v4 string (string_pattern 2.4). If you previously used `:uuid` as a literal value (expecting the symbol or the string `"uuid"`), that behavior has changed.

All other changes are backwards compatible: same method signatures, new optional parameters (`seed:`, etc.), and new methods only added.

### Security

- Replaced `eval` in `NiceHash.set_nested` and `NiceHash.delete_nested` with iterative key traversal to prevent code injection when keys or values come from untrusted input.

### Added

- `respond_to_missing?` for `Hash` and `Array` so `respond_to?(:key_name)` works correctly for method-style key access.
- **`generate_n(n)`**: Generate n different hashes in one call (`NiceHash.generate_n(pattern_hash, n, select_hash_key, expected_errors: [])` and `hash.generate_n(n, ...)` / `hash.gen_n(n, ...)`).
- **`diff(expected, actual)`**: Compare two hashes and get differences with dot-notation paths (`NiceHash.diff` and `hash.diff(other)`).
- **`flatten_keys`** / **`unflatten_keys`**: Convert between nested hashes and flat hashes with dot-notation keys (`NiceHash.flatten_keys`, `NiceHash.unflatten_keys`, `hash.flatten_keys`, `hash.unflatten_keys`).
- **string_pattern 2.4**: Pattern value `:uuid` generates/validates UUID v4; `generate` / `generate_n` accept optional `seed:` for reproducible output.
- Specs for set_nested/delete_nested (including injection-safe behavior), transtring, get_all_keys, String#json, Array#json, nice_filter edge cases, respond_to? for Hash/Array, and the new features above.

### Fixed

- `NiceHash.deep_clone` now correctly handles non-Array/non-Hash values by returning a shallow clone explicitly instead of relying on a no-op else branch.

### Changed

- Gemspec: `required_ruby_version` set to `>= 3.0`.
- CI: Travis now includes Ruby 3.2 and 3.3.

## [1.18.7] - (previous releases)

See git history for earlier changes.
