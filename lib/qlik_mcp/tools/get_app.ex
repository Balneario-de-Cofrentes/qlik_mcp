defmodule QlikMCP.Tools.GetApp do
  @moduledoc """
  Gets detailed information about a specific Qlik app.
  """

  use Anubis.Server.Component, type: :tool

  alias QlikElixir.REST.Apps
  alias QlikMCP.Tools.Helpers

  schema do
    field(:app_id, {:required, :string}, description: "The ID of the app to retrieve")
  end

  @impl true
  def description, do: "Get detailed information about a specific Qlik app"

  @impl true
  def execute(%{"app_id" => app_id}, frame) do
    case Helpers.get_config(frame) do
      {:ok, config} ->
        case Apps.get(app_id, config: config) do
          {:ok, app} ->
            formatted = format_app_details(app)
            {:reply, Helpers.success_response(formatted), frame}

          {:error, error} ->
            {:reply, Helpers.error_response("Failed to get app: #{inspect(error)}"), frame}
        end

      {:error, message} ->
        {:reply, Helpers.error_response(message), frame}
    end
  end

  defp format_app_details(app) do
    attrs = app["attributes"] || %{}

    """
    App Details
    ===========
    Name: #{attrs["name"]}
    ID: #{app["id"]}
    Description: #{attrs["description"] || "N/A"}

    Metadata
    --------
    Owner: #{attrs["ownerId"]}
    Space: #{attrs["spaceId"] || "Personal"}
    Created: #{attrs["createdDate"]}
    Modified: #{attrs["modifiedDate"]}
    Last Reload: #{attrs["lastReloadTime"] || "Never"}
    Published: #{attrs["published"] || false}

    Usage
    -----
    Usage: #{attrs["usage"] || "N/A"}
    Origin App ID: #{attrs["originAppId"] || "N/A"}
    """
  end
end
