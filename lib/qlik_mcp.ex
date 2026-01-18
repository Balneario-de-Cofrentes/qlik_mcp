defmodule QlikMCP do
  @moduledoc """
  QlikMCP - MCP Server for Qlik Cloud.

  This library provides a Model Context Protocol (MCP) server that enables
  AI assistants like Claude to interact with Qlik Cloud. It allows:

  - Listing and exploring Qlik apps, sheets, and visualizations
  - Extracting data from charts and tables
  - Evaluating Qlik expressions
  - Managing apps, spaces, and files
  - Triggering automations and reloads

  ## Quick Start

  1. Set environment variables:

      export QLIK_API_KEY="your-api-key"
      export QLIK_TENANT_URL="https://your-tenant.region.qlikcloud.com"

  2. Start the server:

      mix run --no-halt

  3. Configure Claude Desktop (claude_desktop_config.json):

      {
        "mcpServers": {
          "qlik": {
            "url": "http://localhost:4100/mcp"
          }
        }
      }

  ## Available Tools

  ### Data Extraction (Primary Value)
  - `list_apps` - List available Qlik apps
  - `get_app` - Get app details
  - `list_sheets` - List sheets in an app
  - `list_charts` - List visualizations on a sheet
  - `get_chart_data` - Extract data from a visualization
  - `evaluate_expression` - Calculate a Qlik expression

  ### App Management
  - `reload_app` - Trigger a data reload
  - `get_reload_status` - Check reload progress

  ### Spaces & Files
  - `list_spaces` - List available spaces
  - `list_files` - List data files

  ### Automation
  - `list_automations` - List automations
  - `run_automation` - Trigger an automation

  ## Architecture

  This server uses:
  - [Anubis MCP](https://hex.pm/packages/anubis_mcp) - Elixir MCP SDK
  - [QlikElixir](https://hex.pm/packages/qlik_elixir) - Qlik Cloud client library

  ## Example Interaction

      User: "What's our sales by country from the Q4 dashboard?"

      Claude:
      1. list_apps() → finds "Q4 Sales Dashboard" app
      2. list_sheets(app_id) → finds "Regional Sales" sheet
      3. list_charts(app_id, sheet_id) → finds "Sales by Country" table
      4. get_chart_data(app_id, object_id) → extracts the data
      5. Analyzes and responds with insights
  """

  @doc """
  Returns the current version of QlikMCP.
  """
  def version do
    Application.spec(:qlik_mcp, :vsn) |> to_string()
  end

  @doc """
  Returns the configured port for the HTTP server.
  """
  def port do
    Application.get_env(:qlik_mcp, :port, 4100)
  end

  @doc """
  Checks if the server is configured with valid Qlik credentials.
  """
  def configured? do
    case QlikMCP.Config.get() do
      {:ok, _} -> true
      {:error, _} -> false
    end
  end
end
