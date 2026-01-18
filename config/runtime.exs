import Config

# Runtime configuration - loaded at runtime from environment variables
# This is useful for secrets that shouldn't be in version control

if config_env() != :test do
  # Qlik Cloud credentials from environment
  if api_key = System.get_env("QLIK_API_KEY") do
    config :qlik_mcp, api_key: api_key
  end

  if tenant_url = System.get_env("QLIK_TENANT_URL") do
    config :qlik_mcp, tenant_url: tenant_url
  end

  # Optional overrides
  if port = System.get_env("QLIK_MCP_PORT") do
    config :qlik_mcp, port: String.to_integer(port)
  end

  if max_rows = System.get_env("QLIK_MAX_ROWS") do
    config :qlik_mcp, max_rows: String.to_integer(max_rows)
  end
end
