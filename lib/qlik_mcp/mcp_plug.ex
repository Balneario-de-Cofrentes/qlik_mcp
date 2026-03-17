defmodule QlikMCP.MCPPlug do
  @moduledoc false

  # Thin wrapper that defers Anubis StreamableHTTP.Plug initialization to runtime.
  # The Anubis plug's init/1 reads from persistent_term, which is only available
  # after the server supervisor starts — not at compile time when Plug.Router
  # evaluates forward/2.

  @behaviour Plug

  alias Anubis.Server.Transport.StreamableHTTP

  @impl true
  def init(opts), do: opts

  @impl true
  def call(conn, opts) do
    StreamableHTTP.Plug.call(conn, StreamableHTTP.Plug.init(opts))
  end
end
