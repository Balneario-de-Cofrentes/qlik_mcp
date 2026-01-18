defmodule QlikMCP.Tools.Helpers do
  @moduledoc """
  Shared helpers for QlikMCP tools.
  """

  require Logger

  alias Anubis.Server.Response
  alias QlikElixir.QIX.Session

  @qix_timeout 15_000
  @rest_timeout 60_000  # 60 seconds for REST API calls

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

  # Safely converts a value to string, handling special cases that would crash to_string/1
  defp safe_to_string(nil), do: ""
  defp safe_to_string(v) when is_binary(v), do: v

  defp safe_to_string(v) when is_float(v) do
    cond do
      v != v -> "NaN"  # NaN check
      v * 0 != 0 -> if v > 0, do: "Infinity", else: "-Infinity"  # Infinity check
      true -> to_string(v)
    end
  end

  defp safe_to_string(v) when is_tuple(v) do
    # Handle Qlik-specific tuple formats
    # Qlik returns cells as tuples with :values and :text fields
    # We prefer :text (formatted) over :values (raw numbers)
    case v do
      {:text, text_values} when is_list(text_values) ->
        # Extract text representation from tuple
        Enum.join(text_values, ", ")

      {:values, num_values} when is_list(num_values) ->
        # Fall back to values if no text available
        Enum.map_join(num_values, ", ", &safe_to_string/1)

      _ ->
        # Generic tuple, use inspect as last resort
        inspect(v)
    end
  end

  defp safe_to_string(v) when is_map(v) or is_list(v) do
    case Jason.encode(v) do
      {:ok, json} -> json
      _ -> inspect(v)
    end
  end

  defp safe_to_string(v) do
    to_string(v)
  rescue
    _ -> inspect(v)
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
        |> Enum.map(fn row -> row |> Enum.at(i, "") |> safe_to_string() |> String.length() end)
        |> Enum.max()
      end)

    # Format header
    header_line =
      Enum.zip(headers, widths)
      |> Enum.map_join(" | ", fn {h, w} -> String.pad_trailing(safe_to_string(h), w) end)

    separator = Enum.map_join(widths, "-+-", &String.duplicate("-", &1))

    # Format rows
    data_lines =
      Enum.map_join(rows, "\n", fn row ->
        Enum.zip(row, widths)
        |> Enum.map_join(" | ", fn {v, w} -> String.pad_trailing(safe_to_string(v), w) end)
      end)

    Enum.join([header_line, separator, data_lines], "\n")
  end

  @doc """
  Connects to the QIX Engine for an app and returns the session.
  """
  def connect_qix(app_id, config) do
    Logger.debug("Connecting to QIX Engine for app #{app_id}")
    start_time = System.monotonic_time(:millisecond)

    result = Session.connect(app_id, config: config, timeout: @qix_timeout)

    elapsed = System.monotonic_time(:millisecond) - start_time

    case result do
      {:ok, session} ->
        Logger.debug("QIX connection established in #{elapsed}ms")
        {:ok, session}

      {:error, error} ->
        Logger.error("QIX connection failed after #{elapsed}ms: #{inspect(error)}")
        {:error, error}
    end
  end

  @doc """
  Safely disconnects from a QIX session.
  """
  def disconnect_qix(session) do
    Session.disconnect(session)
  end

  @doc """
  Gets the default QIX request timeout.
  """
  def qix_timeout, do: @qix_timeout

  @doc """
  Wraps a tool execution with comprehensive error handling.
  Catches ALL exceptions and returns proper error responses.
  This prevents server crashes when tools throw exceptions.
  """
  def safe_execute(tool_name, frame, fun) do
    require Logger
    Logger.debug("Executing tool: #{tool_name}")

    try do
      fun.()
    rescue
      error ->
        Logger.error("Tool #{tool_name} crashed: #{Exception.message(error)}")
        Logger.error("Error type: #{inspect(error.__struct__)}")
        Logger.error("Stacktrace: #{Exception.format_stacktrace(__STACKTRACE__)}")
        {:reply, error_response("Tool crashed: #{Exception.message(error)}"), frame}
    catch
      kind, reason ->
        Logger.error("Tool #{tool_name} caught #{kind}: #{inspect(reason)}")
        {:reply, error_response("Tool error: #{inspect(reason)}"), frame}
    end
  end

  @doc """
  Wraps a QIX operation with timeout and logging.
  """
  def with_qix_timeout(operation_name, fun) do
    Logger.debug("Starting QIX operation: #{operation_name}")
    start_time = System.monotonic_time(:millisecond)

    task = Task.async(fun)

    try do
      result = Task.await(task, @qix_timeout)
      elapsed = System.monotonic_time(:millisecond) - start_time
      Logger.debug("QIX operation #{operation_name} completed in #{elapsed}ms")
      result
    catch
      :exit, {:timeout, _} ->
        elapsed = System.monotonic_time(:millisecond) - start_time
        Logger.error("QIX operation #{operation_name} timed out after #{elapsed}ms")
        {:error, "QIX operation timed out after #{@qix_timeout}ms"}
    end
  end

  @doc """
  Executes a QIX operation with connection and timeout.

  This is a convenience wrapper that:
  1. Wraps the entire operation in timeout (including connection)
  2. Handles connection, execution, and disconnection
  3. Returns properly formatted MCP responses
  """
  def execute_qix_operation(app_id, config, operation_name, frame, fun) do
    with_qix_timeout(operation_name, fn ->
      case connect_qix(app_id, config) do
        {:ok, session} ->
          result =
            try do
              fun.(session)
            rescue
              error ->
                Logger.error("QIX operation #{operation_name} raised error: #{inspect(error)}")
                {:reply, error_response("Operation failed: #{inspect(error)}"), frame}
            end

          disconnect_qix(session)
          result

        {:error, error} ->
          {:reply, error_response("Failed to connect: #{inspect(error)}"), frame}
      end
    end)
  end

  @doc """
  Wraps a REST API operation with timeout and logging.
  """
  def with_rest_timeout(operation_name, fun) do
    Logger.debug("Starting REST operation: #{operation_name}")
    start_time = System.monotonic_time(:millisecond)

    task = Task.async(fun)

    try do
      result = Task.await(task, @rest_timeout)
      elapsed = System.monotonic_time(:millisecond) - start_time
      Logger.debug("REST operation #{operation_name} completed in #{elapsed}ms")
      result
    catch
      :exit, {:timeout, _} ->
        elapsed = System.monotonic_time(:millisecond) - start_time
        Logger.error("REST operation #{operation_name} timed out after #{elapsed}ms")
        {:error, "REST operation timed out after #{@rest_timeout}ms"}
    end
  end

  @doc """
  Executes a REST API operation with timeout and logging.
  """
  def execute_rest_operation(config, operation_name, frame, fun) do
    with_rest_timeout(operation_name, fn ->
      try do
        fun.(config)
      rescue
        error ->
          Logger.error("REST operation #{operation_name} raised error: #{inspect(error)}")
          {:reply, error_response("Operation failed: #{inspect(error)}"), frame}
      end
    end)
  end
end
