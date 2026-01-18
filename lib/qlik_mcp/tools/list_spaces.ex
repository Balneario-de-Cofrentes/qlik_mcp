defmodule QlikMCP.Tools.ListSpaces do
  @moduledoc """
  Lists available Qlik spaces.

  Returns a list of spaces (shared, managed, or data) the user has access to.
  """

  use Anubis.Server.Component, type: :tool

  alias QlikElixir.REST.Spaces
  alias QlikMCP.Tools.Helpers

  schema do
    field(:limit, :integer, description: "Maximum number of spaces to return (default: 20)")
    field(:type, :string, description: "Filter by space type: shared, managed, or data")
  end

  @impl true
  def description, do: "List available Qlik spaces"

  @impl true
  def execute(params, frame) do
    case Helpers.get_config(frame) do
      {:ok, config} ->
        opts =
          []
          |> Helpers.maybe_add_opt(params, :limit, :limit)
          |> Helpers.maybe_add_opt(params, :type, :type)

        case Spaces.list(Keyword.put(opts, :config, config)) do
          {:ok, %{"data" => spaces}} ->
            formatted = format_spaces(spaces)
            {:reply, Helpers.success_response(formatted), frame}

          {:error, error} ->
            {:reply, Helpers.error_response("Failed to list spaces: #{inspect(error)}"), frame}
        end

      {:error, message} ->
        {:reply, Helpers.error_response(message), frame}
    end
  end

  defp format_spaces(spaces) do
    if Enum.empty?(spaces) do
      "No spaces found."
    else
      spaces
      |> Enum.map(&format_space/1)
      |> Helpers.to_text_content()
    end
  end

  defp format_space(space) do
    """
    Space: #{space["name"]}
    ID: #{space["id"]}
    Type: #{space["type"]}
    Description: #{space["description"] || "N/A"}
    Owner: #{space["ownerId"]}
    """
  end
end
