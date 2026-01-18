# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
import Config

# Default configuration
config :qlik_mcp,
  port: 4100,
  max_rows: 10_000

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
