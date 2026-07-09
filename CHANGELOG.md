# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.12.0] - 2026-07-08

### Fixed

- Weekly data-update workflow no longer commits timestamp-only changes. Change
  detection now compares against a data hash embedded in the generated
  `data.ex` header, so it works statelessly on a fresh CI checkout instead of
  relying on the local `.mime_cache` directory
- CI now fails when tests fail (removed a stray `set +e` around `mix test`)

### Security

- Updated `req` (0.6.2), `mint` (1.9.1), and `hpax` (1.0.4) to resolve
  security advisories, including HIGH-severity DoS CVEs
  (EEF-CVE-2026-49755, EEF-CVE-2026-56810, EEF-CVE-2026-49754,
  EEF-CVE-2026-48862, EEF-CVE-2026-58226)

### Changed

- Relaxed over-tight dependency constraints and updated all deps
  (`finch` 0.23.0, `ex_doc` 0.40.3, `quokka` 2.13.1, `credo` 1.7.19, etc.)
- Bumped GitHub Actions `checkout` and `cache` to v4

## [0.11.0] - 2024-09-14

### Added

- `get_from_header/1` - Extract and get description from raw MIME headers with parameters
- `get_from_header_with_fallback/2` - Get description from header with custom fallback
- `extract_mime_type/1` - Extract base MIME type from headers, removing parameters
- Support for handling MIME types with charset, boundary, and other parameters
- Comprehensive tests for header parsing functionality
- Real-world email header test cases

### Changed

- Improved documentation with examples for new functions

## [0.1.0] - 2024-09-13

### Added

- Initial release
- Embedded MIME type descriptions from freedesktop.org
- `get/1` - Get description with {:ok, description} or {:error, :not_found}
- `get!/1` - Get description or raise KeyError
- `get_with_default/2` - Get description with fallback value
- Mix task `mix mime_description.generate` for updating MIME data
- Smart change detection (only regenerates when data actually changes)
- GitHub Actions workflow for automated weekly updates
- Comprehensive test coverage
- Support for Elixir 1.15+ and OTP 26+
