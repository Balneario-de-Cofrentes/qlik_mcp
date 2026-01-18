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
    # Wrap entire execution in safe_execute to catch ALL exceptions
    Helpers.safe_execute("get_chart_data", frame, fn ->
      %{app_id: app_id, object_id: object_id} = params
      max_rows = params[:max_rows] || Helpers.get_max_rows(frame)

      case Helpers.get_config(frame) do
      {:ok, config} ->
        # Wrap ENTIRE operation including connection in timeout
        Helpers.with_qix_timeout("get_chart_data_with_connection", fn ->
          case Helpers.connect_qix(app_id, config) do
            {:ok, session} ->
              result =
                case App.get_hypercube_data(session, object_id,
                      max_rows: max_rows,
                      timeout: Helpers.qix_timeout()) do
                  {:ok, data} ->
                    formatted = format_data(data)
                    {:reply, Helpers.success_response(formatted), frame}

                  {:error, error} ->
                    {:reply, Helpers.error_response("Failed to get data: #{inspect(error)}"), frame}
                end

              Helpers.disconnect_qix(session)
              result

            {:error, error} ->
              {:reply, Helpers.error_response("Failed to connect: #{inspect(error)}"), frame}
          end
        end)

        {:error, message} when is_binary(message) ->
          {:reply, Helpers.error_response(message), frame}

        {:error, error} ->
          {:reply, Helpers.error_response("Config error: #{inspect(error)}"), frame}
      end
    end)
  end

  defp format_data(data) do
    headers = get_field(data, :headers, [])
    raw_rows = get_field(data, :rows, [])

    if Enum.empty?(headers) or Enum.empty?(raw_rows) do
      "No data found in this visualization."
    else
      # Extract text arrays from row maps
      # Each row is %{values: [...], text: [...]}, we want just the :text array
      rows = Enum.map(raw_rows, fn row ->
        # Prefer formatted text, fall back to raw values
        get_field(row, :text, []) || get_field(row, :values, [])
      end)

      table = Helpers.format_table(headers, rows)
      table <> format_meta(data, raw_rows)
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
