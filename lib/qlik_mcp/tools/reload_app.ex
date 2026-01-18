defmodule QlikMCP.Tools.ReloadApp do
  @moduledoc """
  Triggers a data reload for a Qlik app.

  Initiates a reload operation to refresh the app's data from its
  data sources. Returns the reload ID for tracking progress.
  """

  use Anubis.Server.Component, type: :tool

  alias QlikElixir.REST.Reloads
  alias QlikMCP.Tools.Helpers

  schema do
    field(:app_id, {:required, :string}, description: "The ID of the app to reload")
    field(:partial, :boolean, description: "Whether to perform a partial reload (default: false)")
  end

  @impl true
  def description, do: "Trigger a data reload for a Qlik app"

  @impl true
  def execute(params, frame) do
    %{"app_id" => app_id} = params
    partial = params["partial"] || false

    case Helpers.get_config(frame) do
      {:ok, config} ->
        case Reloads.create(app_id, partial: partial, config: config) do
          {:ok, reload} ->
            formatted = """
            Reload Started
            ==============
            Reload ID: #{reload["id"]}
            App ID: #{app_id}
            Status: #{reload["status"]}
            Partial: #{partial}

            Use get_reload_status with this reload ID to check progress.
            """

            {:reply, Helpers.success_response(formatted), frame}

          {:error, error} ->
            {:reply, Helpers.error_response("Failed to start reload: #{inspect(error)}"), frame}
        end

      {:error, message} ->
        {:reply, Helpers.error_response(message), frame}
    end
  end
end
