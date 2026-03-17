# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.0] - 2026-03-17

### Changed

- **Breaking:** Upgraded anubis_mcp from ~> 0.17.0 to ~> 1.0
- **Breaking:** Requires Elixir ~> 1.18 (was ~> 1.17)
- Removed `Anubis.Server.Registry` from supervision tree (now managed internally by anubis)
- Router uses runtime plug wrapper to defer StreamableHTTP.Plug initialization

### Added

- Runtime plug wrapper for compile-time/runtime initialization compatibility

### Dependencies

- anubis_mcp 0.17.0 -> 1.0.0
- finch 0.20.0 -> 0.21.0
- telemetry 1.3.0 -> 1.4.1

## [0.1.1] - 2026-01-19

### Changed

- Migrated repository to Balneario-de-Cofrentes organization
- Updated all GitHub URLs to reflect new organization ownership

## [0.1.0] - 2026-01-18

### Added

- Initial release
- MCP Server using Anubis MCP SDK
- HTTP transport with Streamable HTTP protocol (MCP 2025-03-26)

#### Tools
- `list_apps` - List Qlik apps with filtering
- `get_app` - Get app details
- `list_sheets` - List sheets in an app (QIX Engine)
- `list_charts` - List visualizations on a sheet (QIX Engine)
- `get_chart_data` - Extract data from visualizations (QIX Engine)
- `evaluate_expression` - Evaluate Qlik expressions (QIX Engine)
- `reload_app` - Trigger app data reload
- `get_reload_status` - Check reload progress
- `list_spaces` - List available spaces
- `list_files` - List data files
- `list_automations` - List automations
- `run_automation` - Trigger automations

#### Resources
- `qlik://apps` - List of accessible apps
- `qlik://spaces` - List of accessible spaces

### Dependencies
- anubis_mcp ~> 0.17.0
- qlik_elixir ~> 0.3.4
- plug_cowboy ~> 2.7

[0.2.0]: https://github.com/Balneario-de-Cofrentes/qlik_mcp/releases/tag/v0.2.0
[0.1.1]: https://github.com/Balneario-de-Cofrentes/qlik_mcp/releases/tag/v0.1.1
[0.1.0]: https://github.com/dgilperez/qlik_mcp/releases/tag/v0.1.0
