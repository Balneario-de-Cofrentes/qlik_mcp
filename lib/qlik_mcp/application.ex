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
      {Plug.Cowboy, scheme: :http, plug: QlikMCP.Router, options: [port: port()]},

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
