defmodule QlikMCP.ConfigTest do
  use ExUnit.Case, async: true

  alias QlikMCP.Config

  describe "get/0" do
    test "returns error when api_key is missing" do
      # Clear any existing config
      Application.delete_env(:qlik_mcp, :api_key)
      Application.delete_env(:qlik_mcp, :tenant_url)

      assert {:error, "Missing required configuration: QLIK_API_KEY"} = Config.get()
    end
  end

  describe "to_qlik_config/1" do
    test "converts Config struct to QlikElixir config" do
      config = %Config{
        api_key: "test-key",
        tenant_url: "https://test.qlikcloud.com",
        max_rows: 10_000
      }

      result = Config.to_qlik_config(config)

      assert result.api_key == "test-key"
      assert result.tenant_url == "https://test.qlikcloud.com"
    end
  end
end
