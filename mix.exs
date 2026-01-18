defmodule QlikMCP.MixProject do
  use Mix.Project

  @version "0.1.0"
  @source_url "https://github.com/dgilperez/qlik_mcp"

  def project do
    [
      app: :qlik_mcp,
      version: @version,
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),

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
      {:anubis_mcp, "~> 0.17.0"},

      # Qlik Cloud client
      {:qlik_elixir, "~> 0.3.4"},

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
end
