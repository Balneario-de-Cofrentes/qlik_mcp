# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2025-01-18

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

[0.1.0]: https://github.com/dgilperez/qlik_mcp/releases/tag/v0.1.0
