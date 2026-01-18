defmodule QlikMCPTest do
  use ExUnit.Case
  doctest QlikMCP

  describe "version/0" do
    test "returns a version string" do
      version = QlikMCP.version()
      assert is_binary(version)
      assert version =~ ~r/^\d+\.\d+\.\d+/
    end
  end

  describe "port/0" do
    test "returns default port" do
      assert QlikMCP.port() == 4100
    end
  end

  describe "configured?/0" do
    test "returns false when not configured" do
      refute QlikMCP.configured?()
    end
  end
end
