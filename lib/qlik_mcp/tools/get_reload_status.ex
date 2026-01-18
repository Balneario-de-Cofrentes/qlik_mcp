defmodule QlikMCP.Tools.GetReloadStatus do
  @moduledoc """
  Gets the status of a reload operation.

  Retrieves the current status and details of a reload operation
  including progress, duration, and any errors.
  """

  use Anubis.Server.Component, type: :tool

  alias QlikElixir.REST.Reloads
  alias QlikMCP.Tools.Helpers

  schema do
    field(:reload_id, {:required, :string}, description: "The ID of the reload to check")
  end

  @impl true
  def description, do: "Get the status of a Qlik app reload operation"

  @impl true
  def execute(%{"reload_id" => reload_id}, frame) do
    case Helpers.get_config(frame) do
      {:ok, config} ->
        case Reloads.get(reload_id, config: config) do
          {:ok, reload} ->
            formatted = format_reload_status(reload)
            {:reply, Helpers.success_response(formatted), frame}

          {:error, error} ->
            {:reply, Helpers.error_response("Failed to get reload status: #{inspect(error)}"),
             frame}
        end

      {:error, message} ->
        {:reply, Helpers.error_response(message), frame}
    end
  end

  defp format_reload_status(reload) do
    """
    Reload Status
    =============
    Reload ID: #{reload["id"]}
    App ID: #{reload["appId"]}
    Status: #{reload["status"]}
    Partial: #{reload["partial"] || false}

    Timing
    ------
    Started: #{reload["startTime"] || "N/A"}
    Ended: #{reload["endTime"] || "In progress"}
    Duration: #{calculate_duration(reload)}

    #{format_error(reload)}
    """
  end

  defp calculate_duration(reload) do
    case {reload["startTime"], reload["endTime"]} do
      {nil, _} -> "N/A"
      {_, nil} -> "In progress"
      {start, end_time} -> "#{start} to #{end_time}"
    end
  end

  defp format_error(reload) do
    case reload["errorMessage"] || reload["log"] do
      nil -> ""
      "" -> ""
      error -> "Error\n-----\n#{error}"
    end
  end
end
