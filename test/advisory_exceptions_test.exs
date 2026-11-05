defmodule QlikMCP.AdvisoryExceptionsTest do
  use ExUnit.Case, async: true

  # Las excepciones de `mix hex.audit` viven en `mix.exs`
  # (`advisory_exceptions/0`) con fecha de caducidad. Una excepción vencida
  # pone la suite en rojo: o se actualiza el paquete y se quita, o se renueva
  # con un motivo nuevo y otra fecha.
  test "ninguna excepción de seguridad está vencida" do
    today = Date.utc_today()

    for %{id: id, package: package, until: until, reason: reason} <-
          Mix.Project.get!().advisory_exceptions() do
      assert is_binary(reason) and reason != ""

      refute Date.after?(today, until),
             "La excepción #{id} (#{package}) venció el #{until}. Actualiza #{package} y " <>
               "quítala de advisory_exceptions/0 en mix.exs, o renuévala con motivo."
    end
  end
end
