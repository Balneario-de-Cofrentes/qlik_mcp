# QlikMCP

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
git clone https://github.com/dgilperez/qlik_mcp.git
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

## Claude Desktop Integration

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
- [GitHub](https://github.com/dgilperez/qlik_mcp)
- [Qlik Developer Portal](https://qlik.dev/)

---

## Sponsored by

This project is proudly sponsored by **[Balneario - Clínica de Longevidad de Cofrentes](https://balneario.com)**, a world-class longevity clinic and thermal spa in Valencia, Spain. Their support makes open source development like this possible.

Thank you for investing in the developer community!
