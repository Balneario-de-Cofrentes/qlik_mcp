defmodule QlikMCP.Tools.ListApps do
  @moduledoc """
  Lists available Qlik apps with optional filtering.

  Returns a list of apps the user has access to, including their
  ID, name, description, and metadata.
  """

  use Anubis.Server.Component, type: :tool

  alias QlikElixir.REST.Apps
  alias QlikMCP.Tools.Helpers

  schema do
    field(:limit, :integer, description: "Maximum number of apps to return (default: 20)")
    field(:name, :string, description: "Filter apps by name (partial match)")
    field(:space_id, :string, description: "Filter apps by space ID")
  end

  @impl true
  def description, do: "List available Qlik apps with optional filtering"

  @impl true
  def execute(params, frame) do
    case Helpers.get_config(frame) do
      {:ok, config} ->
        opts =
          []
          |> Helpers.maybe_add_opt(params, "limit", :limit)
          |> Helpers.maybe_add_opt(params, "name", :name)
          |> Helpers.maybe_add_opt(params, "space_id", :spaceId)

        case Apps.list(Keyword.put(opts, :config, config)) do
          {:ok, %{"data" => apps}} ->
            formatted = Enum.map_join(apps, "\n---\n", &format_app/1)
            {:reply, Helpers.success_response(formatted), frame}

          {:error, error} ->
            {:reply, Helpers.error_response("Failed to list apps: #{inspect(error)}"), frame}
        end

      {:error, message} ->
        {:reply, Helpers.error_response(message), frame}
    end
  end

  defp format_app(app) do
    """
    App: #{app["attributes"]["name"]}
    ID: #{app["id"]}
    Description: #{app["attributes"]["description"] || "N/A"}
    Owner: #{app["attributes"]["ownerId"]}
    Space: #{app["attributes"]["spaceId"] || "Personal"}
    Last Reload: #{app["attributes"]["lastReloadTime"] || "Never"}
    """
  end
end
