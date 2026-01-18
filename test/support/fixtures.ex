defmodule QlikMCP.Test.Fixtures do
  @moduledoc """
  Test fixtures for QlikMCP tests.
  """

  def app_fixture(attrs \\ %{}) do
    Map.merge(
      %{
        "id" => "app-123",
        "attributes" => %{
          "name" => "Test App",
          "description" => "A test application",
          "ownerId" => "user-456",
          "spaceId" => "space-789",
          "lastReloadTime" => "2025-01-15T10:00:00Z",
          "createdDate" => "2025-01-01T00:00:00Z",
          "modifiedDate" => "2025-01-15T10:00:00Z",
          "published" => false
        }
      },
      attrs
    )
  end

  def space_fixture(attrs \\ %{}) do
    Map.merge(
      %{
        "id" => "space-123",
        "name" => "Test Space",
        "type" => "shared",
        "description" => "A test space",
        "ownerId" => "user-456"
      },
      attrs
    )
  end

  def sheet_fixture(attrs \\ %{}) do
    Map.merge(
      %{
        "id" => "sheet-123",
        "title" => "Test Sheet",
        "description" => "A test sheet",
        "qInfo" => %{"qId" => "sheet-123"},
        "qMeta" => %{"title" => "Test Sheet", "description" => "A test sheet"}
      },
      attrs
    )
  end

  def chart_object_fixture(attrs \\ %{}) do
    Map.merge(
      %{
        "qInfo" => %{"qId" => "chart-123", "qType" => "barchart"},
        "qMeta" => %{"title" => "Sales by Region"},
        "title" => "Sales by Region"
      },
      attrs
    )
  end

  def hypercube_data_fixture(attrs \\ %{}) do
    Map.merge(
      %{
        headers: ["Region", "Sales", "Margin"],
        rows: [
          ["North", "1000000", "0.25"],
          ["South", "850000", "0.22"],
          ["East", "920000", "0.24"],
          ["West", "780000", "0.21"]
        ],
        total_rows: 4,
        truncated: false
      },
      attrs
    )
  end

  def reload_fixture(attrs \\ %{}) do
    Map.merge(
      %{
        "id" => "reload-123",
        "appId" => "app-123",
        "status" => "QUEUED",
        "partial" => false,
        "startTime" => nil,
        "endTime" => nil
      },
      attrs
    )
  end

  def automation_fixture(attrs \\ %{}) do
    Map.merge(
      %{
        "id" => "auto-123",
        "name" => "Test Automation",
        "description" => "A test automation",
        "state" => "enabled",
        "lastRunTime" => "2025-01-15T09:00:00Z"
      },
      attrs
    )
  end

  def file_fixture(attrs \\ %{}) do
    Map.merge(
      %{
        "id" => "file-123",
        "name" => "sales_data.csv",
        "size" => 1_048_576,
        "spaceId" => "space-789",
        "createdDate" => "2025-01-10T00:00:00Z"
      },
      attrs
    )
  end

  def qlik_config_fixture do
    %QlikElixir.Config{
      api_key: "test-api-key",
      tenant_url: "https://test-tenant.us.qlikcloud.com"
    }
  end
end
