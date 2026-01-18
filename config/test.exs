import Config

# Test configuration
config :logger, level: :warning

# Use mocks for Qlik API calls in tests
config :qlik_mcp,
  qlik_rest_client: QlikMCP.Mocks.RESTClient,
  qlik_qix_client: QlikMCP.Mocks.QIXClient
