defmodule QlikMCP.Application do
  @moduledoc """
  Main application supervisor for QlikMCP.

  Starts the MCP server and its dependencies.
  """

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # MCP Server Registry (required by Anubis)
      Anubis.Server.Registry,

      # HTTP endpoint for MCP
      # SSE connections need long idle_timeout to avoid premature disconnection
      {Plug.Cowboy,
       scheme: :http,
       plug: QlikMCP.Router,
       options: [
         port: port(),
         protocol_options: [
           # 30 minutes idle timeout for SSE streams
           idle_timeout: 1_800_000,
           # 2 minutes max for tool call requests (POST)
           # SSE connections (GET) are kept alive by inactivity_timeout
           request_timeout: 120_000,
           # CRITICAL: inactivity_timeout for streaming responses (chunked/SSE)
           inactivity_timeout: 1_800_000
         ]
       ]},

      # The MCP Server
      {QlikMCP.Server, transport: :streamable_http}
    ]

    opts = [strategy: :one_for_one, name: QlikMCP.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp port do
    Application.get_env(:qlik_mcp, :port, 4100)
  end
end
