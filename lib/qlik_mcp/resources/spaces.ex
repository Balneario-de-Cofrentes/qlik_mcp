defmodule QlikMCP.Resources.Spaces do
  @moduledoc """
  MCP Resource for listing Qlik spaces.

  Provides a read-only view of all spaces accessible to the configured user.
  """

  use Anubis.Server.Component,
    type: :resource,
    uri: "qlik://spaces",
    name: "spaces",
    mime_type: "application/json"

  alias Anubis.MCP.Error
  alias Anubis.Server.Response
  alias QlikElixir.REST.Spaces

  @impl true
  def title, do: "Qlik Spaces"

  @impl true
  def description, do: "List of all Qlik spaces accessible to the user"

  @impl true
  def read(_params, frame) do
    case frame.assigns[:qlik_config] do
      nil ->
        {:error, Error.resource(:not_found, %{message: "Qlik not configured"}), frame}

      config ->
        fetch_spaces(config, frame)
    end
  end

  defp fetch_spaces(config, frame) do
    case Spaces.list(limit: 100, config: config) do
      {:ok, %{"data" => spaces}} ->
        formatted = format_spaces(spaces)
        response = Response.resource() |> Response.text(formatted)
        {:reply, response, frame}

      {:error, error} ->
        mcp_error =
          Error.protocol(:internal_error, %{message: "Failed to list spaces: #{inspect(error)}"})

        {:error, mcp_error, frame}
    end
  end

  defp format_spaces(spaces) do
    spaces
    |> Enum.map(fn space ->
      %{
        id: space["id"],
        name: space["name"],
        type: space["type"],
        description: space["description"],
        owner_id: space["ownerId"]
      }
    end)
    |> Jason.encode!(pretty: true)
  end
end
