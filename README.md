# QlikMCP

[![Hex.pm](https://img.shields.io/hexpm/v/qlik_mcp.svg)](https://hex.pm/packages/qlik_mcp)
[![Documentation](https://img.shields.io/badge/docs-hexdocs-blue.svg)](https://hexdocs.pm/qlik_mcp)
[![License](https://img.shields.io/hexpm/l/qlik_mcp.svg)](https://github.com/Balneario-de-Cofrentes/qlik_mcp/blob/master/LICENSE)
[![Downloads](https://img.shields.io/hexpm/dt/qlik_mcp.svg)](https://hex.pm/packages/qlik_mcp)

MCP (Model Context Protocol) server for Qlik Cloud, enabling AI assistants like Claude to interact with your Qlik analytics platform.

## Features

- **Data Extraction**: List apps, sheets, visualizations and extract data from charts
- **Expression Evaluation**: Calculate Qlik expressions on the fly
- **App Management**: Trigger reloads, check reload status
- **Space & Files**: Browse spaces and data files
- **Automation**: List and trigger Qlik automations

## Prerequisites

- Elixir 1.17+
- A Qlik Cloud tenant with API access
- A Qlik Cloud API key

## Installation

### As a standalone server

1. Clone this repository:
```bash
git clone https://github.com/Balneario-de-Cofrentes/qlik_mcp.git
cd qlik_mcp
```

2. Install dependencies:
```bash
mix deps.get
```

3. Configure your Qlik Cloud credentials:
```bash
export QLIK_API_KEY="your-api-key"
export QLIK_TENANT_URL="https://your-tenant.region.qlikcloud.com"
```

4. Start the server:
```bash
mix run --no-halt
```

The MCP server will be available at `http://localhost:4100/mcp`.

### Auto-start on macOS (launchd)

For convenience, you can configure the MCP server to start automatically at login using macOS launchd.

1. Create a startup script at `~/.local/bin/qlik-mcp-start`:

```bash
#!/bin/bash
export HOME="$HOME"
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin"

# If using asdf for Elixir version management:
# source /opt/homebrew/opt/asdf/libexec/asdf.sh

# Set Qlik credentials
export QLIK_API_KEY="your-api-key"
export QLIK_TENANT_URL="https://your-tenant.region.qlikcloud.com"

cd /path/to/qlik-cloud-mcp
exec mix run --no-halt
```

Make it executable:
```bash
chmod +x ~/.local/bin/qlik-mcp-start
```

2. Create a launchd plist at `~/Library/LaunchAgents/com.qlik-mcp.plist`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.org/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.qlik-mcp</string>
    <key>ProgramArguments</key>
    <array>
        <string>/bin/bash</string>
        <string>/Users/YOUR_USERNAME/.local/bin/qlik-mcp-start</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardOutPath</key>
    <string>/Users/YOUR_USERNAME/.local/log/qlik-mcp.log</string>
    <key>StandardErrorPath</key>
    <string>/Users/YOUR_USERNAME/.local/log/qlik-mcp.error.log</string>
</dict>
</plist>
```

3. Create log directory and load the service:

```bash
mkdir -p ~/.local/log
launchctl load ~/Library/LaunchAgents/com.qlik-mcp.plist
```

4. Manage the service:

```bash
# Check status
launchctl list | grep qlik

# Stop
launchctl unload ~/Library/LaunchAgents/com.qlik-mcp.plist

# Start
launchctl load ~/Library/LaunchAgents/com.qlik-mcp.plist

# View logs
tail -f ~/.local/log/qlik-mcp.log
```

### As a dependency

Add to your `mix.exs`:

```elixir
def deps do
  [
    {:qlik_mcp, "~> 0.1.0"}
  ]
end
```

## Configuration

### Timeout Settings

The server is configured with robust timeout protection to prevent hanging:

- **Request Timeout**: 120 seconds (2 minutes) - Maximum time for tool execution
- **Idle Timeout**: 1800 seconds (30 minutes) - SSE connection keepalive
- **Inactivity Timeout**: 1800 seconds (30 minutes) - Streaming response timeout
- **QIX Operation Timeout**: 15 seconds - Individual database query timeout

These are configured in `lib/qlik_mcp/application.ex` and `lib/qlik_mcp/tools/helpers.ex`.

### Environment Variables

| Variable | Required | Description |
|----------|----------|-------------|
| `QLIK_API_KEY` | Yes | Your Qlik Cloud API key |
| `QLIK_TENANT_URL` | Yes | Your tenant URL (e.g., `https://tenant.region.qlikcloud.com`) |
| `QLIK_MCP_PORT` | No | HTTP port (default: 4100) |
| `QLIK_MAX_ROWS` | No | Max rows per data request (default: 10000) |

### Application Config

```elixir
# config/config.exs
config :qlik_mcp,
  api_key: System.get_env("QLIK_API_KEY"),
  tenant_url: System.get_env("QLIK_TENANT_URL"),
  port: 4100,
  max_rows: 10_000
```

## Claude Integration

### Claude Code (CLI)

Add to your `~/.claude.json` in the `mcpServers` section:

```json
{
  "mcpServers": {
    "qlik": {
      "type": "http",
      "url": "http://localhost:4100/mcp"
    }
  }
}
```

### Claude Desktop

Add to your `claude_desktop_config.json`:

```json
{
  "mcpServers": {
    "qlik": {
      "url": "http://localhost:4100/mcp"
    }
  }
}
```

## Available Tools

### Data Extraction (Primary Value)

| Tool | Description |
|------|-------------|
| `list_apps` | List available Qlik apps with optional filtering |
| `get_app` | Get detailed information about a specific app |
| `list_sheets` | List all sheets in an app |
| `list_charts` | List visualizations on a sheet |
| `get_chart_data` | Extract data from a visualization |
| `evaluate_expression` | Calculate a Qlik expression (e.g., `Sum(Sales)`) |

### App Management

| Tool | Description |
|------|-------------|
| `reload_app` | Trigger a data reload for an app |
| `get_reload_status` | Check reload progress |

### Spaces & Files

| Tool | Description |
|------|-------------|
| `list_spaces` | List available spaces |
| `list_files` | List data files |

### Automation

| Tool | Description |
|------|-------------|
| `list_automations` | List available automations |
| `run_automation` | Trigger an automation |

## MCP Resources

| URI | Description |
|-----|-------------|
| `qlik://apps` | JSON list of all accessible apps |
| `qlik://spaces` | JSON list of all accessible spaces |

## Example Interaction

```
User: "What's our sales by country from the Q4 dashboard?"

Claude:
1. list_apps() → finds "Q4 Sales Dashboard" app
2. list_sheets(app_id) → finds "Regional Sales" sheet
3. list_charts(app_id, sheet_id) → finds "Sales by Country" table
4. get_chart_data(app_id, object_id) → extracts:

   | Country | Sales    | Margin |
   |---------|----------|--------|
   | USA     | $1.2M    | 23%    |
   | Germany | $987K    | 19%    |
   | UK      | $654K    | 21%    |

5. Claude analyzes and responds with insights
```

## Architecture

```
qlik-cloud-mcp/
├── lib/
│   ├── qlik_mcp.ex              # Main module
│   ├── qlik_mcp/
│   │   ├── application.ex       # OTP Application
│   │   ├── server.ex            # MCP Server (Anubis)
│   │   ├── config.ex            # Configuration
│   │   ├── router.ex            # HTTP Router (Plug)
│   │   ├── tools/               # MCP Tool implementations
│   │   │   ├── list_apps.ex
│   │   │   ├── get_app.ex
│   │   │   ├── list_sheets.ex
│   │   │   ├── list_charts.ex
│   │   │   ├── get_chart_data.ex
│   │   │   ├── evaluate_expression.ex
│   │   │   ├── reload_app.ex
│   │   │   ├── get_reload_status.ex
│   │   │   ├── list_spaces.ex
│   │   │   ├── list_files.ex
│   │   │   ├── list_automations.ex
│   │   │   ├── run_automation.ex
│   │   │   └── helpers.ex
│   │   └── resources/           # MCP Resource implementations
│   │       ├── apps.ex
│   │       └── spaces.ex
└── mix.exs
```

## Troubleshooting

### Server Logs

When running via launchd, logs are written to `~/.local/log/qlik-mcp.log`.

Check for errors:
```bash
tail -f ~/.local/log/qlik-mcp.log | grep -i error
```

### Common Issues

**Tool hangs or times out:**
- Check QIX timeout (15 seconds default for individual queries)
- Check request timeout (120 seconds default for complete tool execution)
- Verify Qlik Cloud API key is valid: `echo $QLIK_API_KEY`
- Check network connectivity to Qlik Cloud

**Server crashes:**
- Check logs for stack traces in `~/.local/log/qlik-mcp.log`
- Verify all environment variables are set correctly
- All tools have comprehensive exception handling via `safe_execute`
- If crashes persist, open an issue with logs

**Connection issues:**
- Verify server is running: `curl http://localhost:4100/health`
- Check launchd status: `launchctl list | grep qlik-mcp`
- Restart server: `launchctl unload ~/Library/LaunchAgents/com.qlik-mcp.plist && launchctl load ~/Library/LaunchAgents/com.qlik-mcp.plist`

### Reliability & Robustness

The server includes comprehensive timeout and error handling:

1. **HTTP Request Timeout** - Explicit `request_timeout: 120_000` ms prevents indefinite hangs
2. **QIX Operation Timeout** - 15-second timeout wrapper for all database queries
3. **Exception Handling** - All tools wrapped with `safe_execute` to catch and gracefully handle crashes
4. **Data Structure Handling** - Proper extraction of Qlik's complex tuple/map data structures

## Dependencies

- [Anubis MCP](https://hex.pm/packages/anubis_mcp) - Elixir MCP SDK
- [QlikElixir](https://hex.pm/packages/qlik_elixir) - Qlik Cloud client library
- [Plug Cowboy](https://hex.pm/packages/plug_cowboy) - HTTP server

## Development

```bash
# Run tests
mix test

# Run linter
mix lint

# Generate docs
mix docs
```

## Related Projects

- [qlik_elixir](https://github.com/dgilperez/qlik_elixir) - The Qlik Cloud Elixir client this MCP server is built on
- [qlik-mcp](https://github.com/jwaxman19/qlik-mcp) - TypeScript reference implementation

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Write tests first (TDD encouraged)
4. Ensure all checks pass (`mix format && mix credo --strict && mix test`)
5. Commit your changes
6. Push to the branch
7. Open a Pull Request

## License

MIT License - see [LICENSE](LICENSE) file for details.

## Links

- [HexDocs](https://hexdocs.pm/qlik_mcp)
- [Hex.pm](https://hex.pm/packages/qlik_mcp)
- [GitHub](https://github.com/Balneario-de-Cofrentes/qlik_mcp)
- [Qlik Developer Portal](https://qlik.dev/)

---

## Sponsored by

This project is proudly sponsored by **[Balneario - Clínica de Longevidad de Cofrentes](https://balneario.com)**, a world-class longevity clinic and thermal spa in Valencia, Spain. Their support makes open source development like this possible.

Thank you for investing in the developer community!
