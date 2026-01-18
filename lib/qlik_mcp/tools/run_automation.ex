defmodule QlikMCP.Tools.RunAutomation do
  @moduledoc """
  Triggers a Qlik automation.

  Runs a specified automation (no-code workflow) and returns the run ID.
  """

  use Anubis.Server.Component, type: :tool

  alias QlikElixir.REST.Automations
  alias QlikMCP.Tools.Helpers

  schema do
    field(:automation_id, {:required, :string}, description: "The ID of the automation to run")
  end

  @impl true
  def description, do: "Trigger a Qlik automation"

  @impl true
  def execute(%{"automation_id" => automation_id}, frame) do
    case Helpers.get_config(frame) do
      {:ok, config} ->
        case Automations.run(automation_id, config: config) do
          {:ok, run} ->
            formatted = """
            Automation Triggered
            ====================
            Automation ID: #{automation_id}
            Run ID: #{run["id"]}
            Status: #{run["status"] || "Started"}
            """

            {:reply, Helpers.success_response(formatted), frame}

          :ok ->
            formatted = """
            Automation Triggered
            ====================
            Automation ID: #{automation_id}
            Status: Started
            """

            {:reply, Helpers.success_response(formatted), frame}

          {:error, error} ->
            {:reply, Helpers.error_response("Failed to run automation: #{inspect(error)}"), frame}
        end

      {:error, message} ->
        {:reply, Helpers.error_response(message), frame}
    end
  end
end
