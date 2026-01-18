defmodule QlikMCP.Resources.Apps do
  @moduledoc """
  MCP Resource for listing Qlik apps.

  Provides a read-only view of all apps accessible to the configured user.
  """

  use Anubis.Server.Component,
    type: :resource,
    uri: "qlik://apps",
    name: "apps",
    mime_type: "application/json"

  alias Anubis.MCP.Error
  alias Anubis.Server.Response
  alias QlikElixir.REST.Apps

  @impl true
  def title, do: "Qlik Apps"

  @impl true
  def description, do: "List of all Qlik apps accessible to the user"

  @impl true
  def read(_params, frame) do
    case frame.assigns[:qlik_config] do
      nil ->
        {:error, Error.resource(:not_found, %{message: "Qlik not configured"}), frame}

      config ->
        fetch_apps(config, frame)
    end
  end

  defp fetch_apps(config, frame) do
    case Apps.list(limit: 100, config: config) do
      {:ok, %{"data" => apps}} ->
        formatted = format_apps(apps)
        response = Response.resource() |> Response.text(formatted)
        {:reply, response, frame}

      {:error, error} ->
        mcp_error =
          Error.protocol(:internal_error, %{message: "Failed to list apps: #{inspect(error)}"})

        {:error, mcp_error, frame}
    end
  end

  defp format_apps(apps) do
    apps
    |> Enum.map(fn app ->
      %{
        id: app["id"],
        name: app["attributes"]["name"],
        description: app["attributes"]["description"],
        space_id: app["attributes"]["spaceId"],
        owner_id: app["attributes"]["ownerId"],
        last_reload: app["attributes"]["lastReloadTime"]
      }
    end)
    |> Jason.encode!(pretty: true)
  end
end
