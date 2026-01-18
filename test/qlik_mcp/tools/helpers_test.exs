defmodule QlikMCP.Tools.HelpersTest do
  use ExUnit.Case, async: true

  alias QlikMCP.Tools.Helpers

  describe "format_table/2" do
    test "formats a simple table" do
      headers = ["Name", "Value"]
      rows = [["foo", "1"], ["bar", "2"]]

      result = Helpers.format_table(headers, rows)

      assert result =~ "Name"
      assert result =~ "Value"
      assert result =~ "foo"
      assert result =~ "bar"
      assert result =~ "---"
    end

    test "handles varying column widths" do
      headers = ["Short", "A Very Long Header"]
      rows = [["x", "y"], ["longer value", "z"]]

      result = Helpers.format_table(headers, rows)

      # Should pad columns appropriately
      assert result =~ "Short"
      assert result =~ "A Very Long Header"
    end

    test "handles empty rows" do
      headers = ["Col1", "Col2"]
      rows = []

      result = Helpers.format_table(headers, rows)

      assert result =~ "Col1"
      assert result =~ "Col2"
    end
  end

  describe "to_text_content/1" do
    test "joins items with separator" do
      items = ["Item 1", "Item 2", "Item 3"]

      result = Helpers.to_text_content(items)

      assert result == "Item 1\n---\nItem 2\n---\nItem 3"
    end

    test "handles single item" do
      result = Helpers.to_text_content(["Single"])
      assert result == "Single"
    end

    test "handles empty list" do
      result = Helpers.to_text_content([])
      assert result == ""
    end
  end

  describe "maybe_add_opt/4" do
    test "adds option when param exists" do
      opts = []
      params = %{"limit" => 10}

      result = Helpers.maybe_add_opt(opts, params, "limit", :limit)

      assert result == [limit: 10]
    end

    test "does not add option when param is nil" do
      opts = [existing: :value]
      params = %{}

      result = Helpers.maybe_add_opt(opts, params, "limit", :limit)

      assert result == [existing: :value]
    end

    test "does not add option when param is empty string" do
      opts = []
      params = %{"name" => ""}

      result = Helpers.maybe_add_opt(opts, params, "name", :name)

      assert result == []
    end
  end

  describe "get_config/1" do
    test "returns error when qlik_config not in assigns" do
      frame = %{assigns: %{}}

      assert {:error, message} = Helpers.get_config(frame)
      assert message =~ "not configured"
    end

    test "returns config when present in assigns" do
      config = %QlikElixir.Config{api_key: "test", tenant_url: "https://test.qlikcloud.com"}
      frame = %{assigns: %{qlik_config: config}}

      assert {:ok, ^config} = Helpers.get_config(frame)
    end
  end

  describe "get_max_rows/1" do
    test "returns max_rows from assigns" do
      frame = %{assigns: %{max_rows: 5000}}

      assert Helpers.get_max_rows(frame) == 5000
    end

    test "returns default when not in assigns" do
      frame = %{assigns: %{}}

      assert Helpers.get_max_rows(frame) == 10_000
    end
  end

  describe "success_response/1" do
    test "creates a tool response with text" do
      response = Helpers.success_response("Test content")

      assert response.type == :tool
      # Anubis uses map with string keys for content
      content = hd(response.content)
      assert content["type"] == "text"
      assert content["text"] == "Test content"
    end
  end

  describe "error_response/1" do
    test "creates an error tool response" do
      response = Helpers.error_response("Something went wrong")

      assert response.type == :tool
      # Anubis uses isError (camelCase)
      assert response.isError == true
    end
  end
end
