defmodule QlikMCP.Tools.EvaluateExpression do
  @moduledoc """
  Evaluates a Qlik expression in an app.

  Connects to the QIX Engine and evaluates a Qlik expression,
  returning the calculated result. Useful for ad-hoc calculations
  like Sum(Sales), Count(Customers), etc.
  """

  use Anubis.Server.Component, type: :tool

  alias QlikElixir.QIX.App
  alias QlikMCP.Tools.Helpers

  schema do
    field(:app_id, {:required, :string}, description: "The ID of the app")

    field(:expression, {:required, :string},
      description: "The Qlik expression to evaluate (e.g., 'Sum(Sales)')"
    )
  end

  @impl true
  def description, do: "Evaluate a Qlik expression (e.g., 'Sum(Sales)', 'Count(Customers)')"

  @impl true
  def execute(%{app_id: app_id, expression: expression}, frame) do
    # Wrap entire execution in safe_execute to catch ALL exceptions
    Helpers.safe_execute("evaluate_expression", frame, fn ->
      case Helpers.get_config(frame) do
      {:ok, config} ->
        # Wrap ENTIRE operation including connection in timeout
        Helpers.with_qix_timeout("evaluate_expression_with_connection", fn ->
          case Helpers.connect_qix(app_id, config) do
            {:ok, session} ->
              result =
                case App.evaluate(session, expression, timeout: Helpers.qix_timeout()) do
                  {:ok, value} ->
                    formatted = """
                    Expression: #{expression}
                    Result: #{value}
                    """

                    {:reply, Helpers.success_response(formatted), frame}

                  {:error, error} ->
                    {:reply, Helpers.error_response("Failed to evaluate: #{inspect(error)}"), frame}
                end

              Helpers.disconnect_qix(session)
              result

            {:error, error} ->
              {:reply, Helpers.error_response("Failed to connect: #{inspect(error)}"), frame}
          end
        end)

        {:error, message} when is_binary(message) ->
          {:reply, Helpers.error_response(message), frame}

        {:error, error} ->
          {:reply, Helpers.error_response("Config error: #{inspect(error)}"), frame}
      end
    end)
  end
end
