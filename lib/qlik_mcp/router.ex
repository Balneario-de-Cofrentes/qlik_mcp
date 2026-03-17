defmodule QlikMCP.Router do
  @moduledoc """
  HTTP Router for QlikMCP.

  Routes MCP protocol requests to the server via the streamable HTTP transport.
  """

  use Plug.Router

  plug(Plug.Logger)
  plug(:match)
  plug(:dispatch)

  # MCP endpoint - uses a runtime wrapper since the Anubis plug's init/1
  # accesses persistent_term set during supervisor startup, not at compile time.
  forward("/mcp",
    to: QlikMCP.MCPPlug,
    init_opts: [server: QlikMCP.Server]
  )

  # Health check endpoint
  get "/health" do
    send_resp(conn, 200, Jason.encode!(%{status: "ok", server: "qlik-mcp"}))
  end

  # Info endpoint
  get "/" do
    info = %{
      name: "qlik-cloud-mcp",
      version: Application.spec(:qlik_mcp, :vsn) |> to_string(),
      description: "MCP Server for Qlik Cloud",
      endpoints: %{
        mcp: "/mcp",
        health: "/health"
      }
    }

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Jason.encode!(info, pretty: true))
  end

  match _ do
    send_resp(conn, 404, Jason.encode!(%{error: "Not found"}))
  end
end
