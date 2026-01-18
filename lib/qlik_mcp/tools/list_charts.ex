defmodule QlikMCP.Tools.ListCharts do
  @moduledoc """
  Lists all visualization objects (charts, tables) on a sheet.

  Connects to the QIX Engine to retrieve the list of objects
  on a specific sheet with their IDs, types, and titles.
  """

  use Anubis.Server.Component, type: :tool

  alias QlikElixir.QIX.App
  alias QlikMCP.Tools.Helpers

  schema do
    field(:app_id, {:required, :string}, description: "The ID of the app")

    field(:sheet_id, {:required, :string},
      description: "The ID of the sheet to list objects from"
    )
  end

  @impl true
  def description, do: "List all charts and visualizations on a sheet"

  @impl true
  def execute(%{app_id: app_id, sheet_id: sheet_id}, frame) do
    Helpers.safe_execute("list_charts", frame, fn ->
      case Helpers.get_config(frame) do
        {:ok, config} ->
          Helpers.execute_qix_operation(app_id, config, "list_charts", frame, fn session ->
            case App.list_objects(session, sheet_id, timeout: Helpers.qix_timeout()) do
              {:ok, objects} ->
                formatted = format_objects(objects, sheet_id)
                {:reply, Helpers.success_response(formatted), frame}

              {:error, error} ->
                {:reply, Helpers.error_response("Failed to list objects: #{inspect(error)}"), frame}
            end
          end)

        {:error, message} when is_binary(message) ->
          {:reply, Helpers.error_response(message), frame}

        {:error, error} ->
          {:reply, Helpers.error_response("Config error: #{inspect(error)}"), frame}
      end
    end)
  end

  defp format_objects(objects, sheet_id) do
    if Enum.empty?(objects) do
      "No visualization objects found on sheet #{sheet_id}."
    else
      header = "Visualizations on Sheet\n=======================\n"

      object_list =
        Enum.map_join(objects, "\n---\n", fn obj ->
          """
          Object: #{get_title(obj)}
          ID: #{obj["qInfo"]["qId"]}
          Type: #{obj["qInfo"]["qType"]}
          """
        end)

      header <> object_list
    end
  end

  defp get_title(obj) do
    obj["title"] ||
      get_in(obj, ["qMeta", "title"]) ||
      obj["qInfo"]["qType"] ||
      "Untitled"
  end
end
