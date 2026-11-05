defmodule QlikMCP.MixProject do
  use Mix.Project

  @version "0.2.0"
  @source_url "https://github.com/Balneario-de-Cofrentes/qlik_mcp"

  def project do
    [
      app: :qlik_mcp,
      version: @version,
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),
      # test/support is loaded by test_helper.exs, not run as tests.
      test_ignore_filters: [&String.starts_with?(&1, "test/support/")],
      hex: [ignore_advisories: Enum.map(advisory_exceptions(), & &1.id)],

      # Hex
      name: "QlikMCP",
      description: "MCP (Model Context Protocol) server for Qlik Cloud",
      package: package(),
      source_url: @source_url,
      docs: docs()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {QlikMCP.Application, []}
    ]
  end

  defp deps do
    [
      # MCP Protocol
      {:anubis_mcp, "~> 1.0"},

      # Qlik Cloud client
      {:qlik_elixir, "~> 0.4.1"},

      # HTTP Server for MCP transport
      {:plug_cowboy, "~> 2.7"},
      {:plug, "~> 1.16"},

      # JSON
      {:jason, "~> 1.4"},

      # Development
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.34", only: :dev, runtime: false},

      # Testing
      {:bypass, "~> 2.1", only: :test},
      {:mox, "~> 1.1", only: :test}
    ]
  end

  defp aliases do
    [
      lint: ["format --check-formatted", "credo --strict"],
      "deps.check": ["deps.unlock --check-unused", "hex.outdated"]
    ]
  end

  defp package do
    [
      licenses: ["MIT"],
      links: %{
        "GitHub" => @source_url,
        "QlikElixir" => "https://hex.pm/packages/qlik_elixir"
      },
      maintainers: ["David Gil"]
    ]
  end

  defp docs do
    [
      main: "readme",
      extras: ["README.md", "CHANGELOG.md", "LICENSE"],
      source_ref: "v#{@version}",
      source_url: @source_url
    ]
  end

  # Excepciones de `mix hex.audit` para avisos sin versión arreglada
  # publicada. Cada una caduca: test/advisory_exceptions_test.exs pone la
  # suite en rojo cuando vence, para actualizar el paquete o renovarla con
  # un motivo nuevo.
  def advisory_exceptions do
    [
      %{
        id: "EEF-CVE-2026-43966",
        package: "cowlib",
        until: ~D[2026-12-05],
        reason:
          "Sin versión arreglada publicada; cowlib llega vía plug_cowboy/cowboy y gun (qlik_elixir) y el fallo está en cow_http_struct_hd:escape_string/2, que solo se usa al serializar cabeceras estructuradas que este repo no emite ni construye con datos de usuario."
      },
      %{
        id: "GHSA-w4f7-4cxr-rv3c",
        package: "gun",
        until: ~D[2026-12-05],
        reason:
          "Sin versión arreglada publicada; mismo origen que EEF-CVE-2026-43966 (cow_http_struct_hd de cowlib), gun llega vía qlik_elixir y nunca envía cabeceras estructuradas construidas con datos de usuario."
      }
    ]
  end
end
