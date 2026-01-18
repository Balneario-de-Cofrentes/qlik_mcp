defmodule QlikMCP.Tools.Helpers do
  @moduledoc """
  Shared helpers for QlikMCP tools.
  """

  alias Anubis.Server.Response
  alias QlikElixir.QIX.Session

  @doc """
  Gets the Qlik configuration from the frame.
  """
  def get_config(frame) do
    case frame.assigns[:qlik_config] do
      nil ->
        {:error,
         "Qlik Cloud not configured. Set QLIK_API_KEY and QLIK_TENANT_URL environment variables."}

      config ->
        {:ok, config}
    end
  end

  @doc """
  Gets the max rows setting from the frame.
  """
  def get_max_rows(frame) do
    frame.assigns[:max_rows] || 10_000
  end

  @doc """
  Creates a successful MCP response with text content for tools.
  """
  def success_response(text) when is_binary(text) do
    Response.tool()
    |> Response.text(text)
  end

  @doc """
  Creates an error MCP response.
  """
  def error_response(message) when is_binary(message) do
    Response.tool()
    |> Response.error("Error: #{message}")
  end

  @doc """
  Converts a list of formatted items to a single text content string.
  """
  def to_text_content(items) when is_list(items) do
    Enum.join(items, "\n---\n")
  end

  @doc """
  Maybe adds an option to the opts list if the param exists.
  """
  def maybe_add_opt(opts, params, param_key, opt_key) do
    case Map.get(params, param_key) do
      nil -> opts
      "" -> opts
      value -> Keyword.put(opts, opt_key, value)
    end
  end

  @doc """
  Formats a table of data with headers and rows.
  """
  def format_table(headers, rows) do
    # Calculate column widths
    all_data = [headers | rows]

    widths =
      headers
      |> Enum.with_index()
      |> Enum.map(fn {_, i} ->
        all_data
        |> Enum.map(fn row -> row |> Enum.at(i, "") |> to_string() |> String.length() end)
        |> Enum.max()
      end)

    # Format header
    header_line =
      Enum.zip(headers, widths)
      |> Enum.map_join(" | ", fn {h, w} -> String.pad_trailing(to_string(h), w) end)

    separator = Enum.map_join(widths, "-+-", &String.duplicate("-", &1))

    # Format rows
    data_lines =
      Enum.map_join(rows, "\n", fn row ->
        Enum.zip(row, widths)
        |> Enum.map_join(" | ", fn {v, w} -> String.pad_trailing(to_string(v), w) end)
      end)

    Enum.join([header_line, separator, data_lines], "\n")
  end

  @doc """
  Connects to the QIX Engine for an app and returns the session.
  """
  def connect_qix(app_id, config) do
    Session.connect(app_id, config: config)
  end

  @doc """
  Safely disconnects from a QIX session.
  """
  def disconnect_qix(session) do
    Session.disconnect(session)
  end
end
