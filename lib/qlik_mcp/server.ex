defmodule QlikMCP.Server do
  @moduledoc """
  MCP Server for Qlik Cloud.

  This server provides tools for interacting with Qlik Cloud through the
  Model Context Protocol (MCP). It enables AI assistants to:

  - List and explore Qlik apps, sheets, and visualizations
  - Extract data from charts and tables
  - Evaluate Qlik expressions
  - Manage apps, spaces, and files
  - Trigger automations and reloads

  ## Architecture

  The server uses QlikElixir as the underlying client library and exposes
  Qlik Cloud functionality through MCP tools and resources.

  ## Configuration

  Set the following environment variables:

  - `QLIK_API_KEY` - Your Qlik Cloud API key
  - `QLIK_TENANT_URL` - Your tenant URL (e.g., https://tenant.region.qlikcloud.com)
  """

  use Anubis.Server,
    name: "qlik-cloud-mcp",
    version: QlikMCP.MixProject.project()[:version] || "0.1.0",
    capabilities: [:tools, :resources]

  # Data Extraction Tools (Primary Value)
  component(QlikMCP.Tools.ListApps)
  component(QlikMCP.Tools.GetApp)
  component(QlikMCP.Tools.ListSheets)
  component(QlikMCP.Tools.ListCharts)
  component(QlikMCP.Tools.GetChartData)
  component(QlikMCP.Tools.EvaluateExpression)

  # App Management Tools
  component(QlikMCP.Tools.ReloadApp)
  component(QlikMCP.Tools.GetReloadStatus)

  # Space & Files Tools
  component(QlikMCP.Tools.ListSpaces)
  component(QlikMCP.Tools.ListFiles)

  # Automation Tools
  component(QlikMCP.Tools.ListAutomations)
  component(QlikMCP.Tools.RunAutomation)

  # Resources
  component(QlikMCP.Resources.Apps)
  component(QlikMCP.Resources.Spaces)

  @impl true
  def init(_client_info, frame) do
    # Validate configuration on startup
    case QlikMCP.Config.get() do
      {:ok, config} ->
        qlik_config = QlikMCP.Config.to_qlik_config(config)

        frame =
          frame
          |> assign(:qlik_config, qlik_config)
          |> assign(:max_rows, config.max_rows)

        {:ok, frame}

      {:error, reason} ->
        # Log warning but allow server to start - tools will fail gracefully
        require Logger
        Logger.warning("QlikMCP: #{reason}. Tools will fail until configuration is provided.")
        {:ok, frame}
    end
  end
end
