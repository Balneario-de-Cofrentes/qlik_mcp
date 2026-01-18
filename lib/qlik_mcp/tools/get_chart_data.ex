defmodule QlikMCP.Tools.GetChartData do
  @moduledoc """
  Extracts data from a visualization object.

  This is the primary data extraction tool. It connects to the QIX Engine
  and retrieves the hypercube data from a chart or table, returning the
  dimensions, measures, and data rows.
  """

  use Anubis.Server.Component, type: :tool

  alias QlikElixir.QIX.App
  alias QlikMCP.Tools.Helpers

  schema do
    field(:app_id, {:required, :string}, description: "The ID of the app")
    field(:object_id, {:required, :string}, description: "The ID of the visualization object")

    field(:max_rows, :integer,
      description: "Maximum rows to retrieve (default: from config or 10000)"
    )
  end

  @impl true
  def description, do: "Extract data from a Qlik visualization (chart, table, etc.)"

  @impl true
  def execute(params, frame) do
    %{"app_id" => app_id, "object_id" => object_id} = params
    max_rows = params["max_rows"] || Helpers.get_max_rows(frame)

    with {:ok, config} <- Helpers.get_config(frame),
         {:ok, session} <- Helpers.connect_qix(app_id, config) do
      result =
        case App.get_hypercube_data(session, object_id, max_rows: max_rows) do
          {:ok, data} ->
            formatted = format_data(data)
            {:reply, Helpers.success_response(formatted), frame}

          {:error, error} ->
            {:reply, Helpers.error_response("Failed to get data: #{inspect(error)}"), frame}
        end

      Helpers.disconnect_qix(session)
      result
    else
      {:error, message} when is_binary(message) ->
        {:reply, Helpers.error_response(message), frame}

      {:error, error} ->
        {:reply, Helpers.error_response("Failed to connect: #{inspect(error)}"), frame}
    end
  end

  defp format_data(data) do
    headers = get_field(data, :headers, [])
    rows = get_field(data, :rows, [])

    if Enum.empty?(headers) and Enum.empty?(rows) do
      "No data found in this visualization."
    else
      table = Helpers.format_table(headers, rows)
      table <> format_meta(data, rows)
    end
  end

  defp get_field(data, key, default) do
    data[key] || data[to_string(key)] || default
  end

  defp format_meta(data, rows) do
    total = get_field(data, :total_rows, length(rows))
    truncated = get_field(data, :truncated, false)

    if truncated do
      "\n\n[Data truncated. Showing #{length(rows)} of #{total} total rows]"
    else
      "\n\n[Total rows: #{total}]"
    end
  end
end
