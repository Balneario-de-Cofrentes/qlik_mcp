defmodule QlikMCP.Tools.ListSheets do
  @moduledoc """
  Lists all sheets in a Qlik app.

  Connects to the QIX Engine to retrieve the list of sheets
  with their IDs and titles.
  """

  use Anubis.Server.Component, type: :tool

  alias QlikElixir.QIX.App
  alias QlikMCP.Tools.Helpers

  schema do
    field(:app_id, {:required, :string}, description: "The ID of the app to list sheets from")
  end

  @impl true
  def description, do: "List all sheets in a Qlik app"

  @impl true
  def execute(%{app_id: app_id}, frame) do
    Helpers.safe_execute("list_sheets", frame, fn ->
      case Helpers.get_config(frame) do
      {:ok, config} ->
        Helpers.execute_qix_operation(app_id, config, "list_sheets", frame, fn session ->
          case App.list_sheets(session, timeout: Helpers.qix_timeout()) do
            {:ok, sheets} ->
              formatted = format_sheets(sheets)
              {:reply, Helpers.success_response(formatted), frame}

            {:error, error} ->
              {:reply, Helpers.error_response("Failed to list sheets: #{inspect(error)}"), frame}
          end
        end)

        {:error, message} when is_binary(message) ->
          {:reply, Helpers.error_response(message), frame}

        {:error, error} ->
          {:reply, Helpers.error_response("Config error: #{inspect(error)}"), frame}
      end
    end)
  end

  defp format_sheets(sheets) do
    if Enum.empty?(sheets) do
      "No sheets found in this app."
    else
      header = "Sheets in App\n=============\n"

      sheet_list =
        Enum.map_join(sheets, "\n---\n", fn sheet ->
          """
          Sheet: #{sheet["title"] || sheet["qMeta"]["title"]}
          ID: #{sheet["id"] || sheet["qInfo"]["qId"]}
          Description: #{get_description(sheet)}
          """
        end)

      header <> sheet_list
    end
  end

  defp get_description(sheet) do
    sheet["description"] ||
      get_in(sheet, ["qMeta", "description"]) ||
      "N/A"
  end
end
