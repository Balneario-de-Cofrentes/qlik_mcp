defmodule QlikMCP.Tools.ListAutomations do
  @moduledoc """
  Lists available Qlik automations.

  Returns a list of automations (no-code workflows) the user has access to.
  """

  use Anubis.Server.Component, type: :tool

  alias QlikElixir.REST.Automations
  alias QlikMCP.Tools.Helpers

  schema do
    field(:limit, :integer, description: "Maximum number of automations to return (default: 20)")
  end

  @impl true
  def description, do: "List available Qlik automations"

  @impl true
  def execute(params, frame) do
    case Helpers.get_config(frame) do
      {:ok, config} ->
        opts =
          []
          |> Helpers.maybe_add_opt(params, :limit, :limit)

        case Automations.list(Keyword.put(opts, :config, config)) do
          {:ok, %{"data" => automations}} ->
            formatted = format_automations(automations)
            {:reply, Helpers.success_response(formatted), frame}

          {:error, error} ->
            {:reply, Helpers.error_response("Failed to list automations: #{inspect(error)}"),
             frame}
        end

      {:error, message} ->
        {:reply, Helpers.error_response(message), frame}
    end
  end

  defp format_automations(automations) do
    if Enum.empty?(automations) do
      "No automations found."
    else
      automations
      |> Enum.map(&format_automation/1)
      |> Helpers.to_text_content()
    end
  end

  defp format_automation(automation) do
    """
    Automation: #{automation["name"]}
    ID: #{automation["id"]}
    State: #{automation["state"]}
    Description: #{automation["description"] || "N/A"}
    Last Run: #{automation["lastRunTime"] || "Never"}
    """
  end
end
