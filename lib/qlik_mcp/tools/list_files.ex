defmodule QlikMCP.Tools.ListFiles do
  @moduledoc """
  Lists data files in Qlik Cloud.

  Returns a list of data files (CSV, Excel, etc.) available in the tenant.
  """

  use Anubis.Server.Component, type: :tool

  alias QlikElixir.REST.DataFiles
  alias QlikMCP.Tools.Helpers

  schema do
    field(:limit, :integer, description: "Maximum number of files to return (default: 20)")
    field(:space_id, :string, description: "Filter files by space ID")
  end

  @impl true
  def description, do: "List data files in Qlik Cloud"

  @impl true
  def execute(params, frame) do
    case Helpers.get_config(frame) do
      {:ok, config} ->
        opts =
          []
          |> Helpers.maybe_add_opt(params, :limit, :limit)
          |> Helpers.maybe_add_opt(params, :space_id, :spaceId)

        case DataFiles.list(Keyword.put(opts, :config, config)) do
          {:ok, %{"data" => files}} ->
            formatted = format_files(files)
            {:reply, Helpers.success_response(formatted), frame}

          {:error, error} ->
            {:reply, Helpers.error_response("Failed to list files: #{inspect(error)}"), frame}
        end

      {:error, message} ->
        {:reply, Helpers.error_response(message), frame}
    end
  end

  defp format_files(files) do
    if Enum.empty?(files) do
      "No data files found."
    else
      files
      |> Enum.map(&format_file/1)
      |> Helpers.to_text_content()
    end
  end

  defp format_file(file) do
    """
    File: #{file["name"]}
    ID: #{file["id"]}
    Size: #{format_size(file["size"])}
    Space: #{file["spaceId"] || "Personal"}
    Created: #{file["createdDate"]}
    """
  end

  defp format_size(nil), do: "Unknown"
  defp format_size(bytes) when bytes < 1024, do: "#{bytes} B"
  defp format_size(bytes) when bytes < 1_048_576, do: "#{Float.round(bytes / 1024, 1)} KB"
  defp format_size(bytes), do: "#{Float.round(bytes / 1_048_576, 1)} MB"
end
