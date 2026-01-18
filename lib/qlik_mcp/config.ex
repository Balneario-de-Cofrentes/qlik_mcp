defmodule QlikMCP.Config do
  @moduledoc """
  Configuration management for QlikMCP.

  Reads configuration from environment variables or application config.

  ## Environment Variables

  - `QLIK_API_KEY` - Required. Your Qlik Cloud API key.
  - `QLIK_TENANT_URL` - Required. Your Qlik Cloud tenant URL (e.g., `https://tenant.region.qlikcloud.com`).
  - `QLIK_MCP_PORT` - Optional. Port for the MCP HTTP server (default: 4100).
  - `QLIK_MAX_ROWS` - Optional. Maximum rows to fetch per chart data request (default: 10000).
  """

  @type t :: %__MODULE__{
          api_key: String.t(),
          tenant_url: String.t(),
          max_rows: pos_integer()
        }

  defstruct [:api_key, :tenant_url, max_rows: 10_000]

  @doc """
  Gets the current Qlik configuration.

  Returns `{:ok, config}` or `{:error, reason}` if configuration is missing.
  """
  @spec get() :: {:ok, t()} | {:error, String.t()}
  def get do
    with {:ok, api_key} <- get_required(:api_key, "QLIK_API_KEY"),
         {:ok, tenant_url} <- get_required(:tenant_url, "QLIK_TENANT_URL") do
      {:ok,
       %__MODULE__{
         api_key: api_key,
         tenant_url: normalize_url(tenant_url),
         max_rows: get_optional(:max_rows, "QLIK_MAX_ROWS", 10_000)
       }}
    end
  end

  @doc """
  Gets configuration, raising if missing required values.
  """
  @spec get!() :: t()
  def get! do
    case get() do
      {:ok, config} -> config
      {:error, reason} -> raise ArgumentError, reason
    end
  end

  @doc """
  Creates a QlikElixir config from our config.
  """
  @spec to_qlik_config(t()) :: map()
  def to_qlik_config(%__MODULE__{} = config) do
    QlikElixir.new_config(
      api_key: config.api_key,
      tenant_url: config.tenant_url
    )
  end

  defp get_required(key, env_var) do
    value =
      Application.get_env(:qlik_mcp, key) ||
        System.get_env(env_var)

    if value && value != "" do
      {:ok, value}
    else
      {:error, "Missing required configuration: #{env_var}"}
    end
  end

  defp get_optional(key, env_var, default) do
    value =
      Application.get_env(:qlik_mcp, key) ||
        System.get_env(env_var)

    case value do
      nil -> default
      "" -> default
      str when is_binary(str) -> String.to_integer(str)
      int when is_integer(int) -> int
    end
  end

  defp normalize_url(url) do
    url
    |> String.trim()
    |> String.trim_trailing("/")
  end
end
