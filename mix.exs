defmodule TailscaleTransport.MixProject do
  use Mix.Project

  @version "0.1.0"

  def project do
    [
      app: :tailscale_transport,
      name: "TailscaleTransport",
      version: @version,
      elixir: "~> 1.17",
      source_url: "https://github.com/Munksgaard/tailscale_transport",
      description: description(),
      package: package(),
      deps: deps(),
      docs: docs()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:thousand_island, "~> 1.3.12"},
      {:gen_tailscale, "~> 0.1.0"},
      {:plug, "~> 1.15"},
      {:req, "~> 0.5"},

      # Testing and development deps
      {:ex_doc, "~> 0.38", only: :dev, runtime: false, warn_if_outdated: true},
      {:phoenix_playground, "~> 0.1.7", only: [:dev, :test]}
    ]
  end

  defp description do
    """
    A transport for ThousandIsland that allows exposing services directly to your tailnet.
    """
  end

  defp package do
    [
      maintainers: ["Philip Munksgaard"],
      licenses: ["Apache-2.0"],
      links: links(),
      files: [
        "lib",
        "mix.exs",
        "README*",
        "CHANGELOG*",
        "LICENSE*"
      ]
    ]
  end

  def links do
    %{
      "GitHub" => "https://github.com/Munksgaard/tailscale_transport"
    }
  end

  defp docs do
    [
      source_ref: "v#{@version}",
      main: "readme",
      extras: [
        "README.md",
        "LICENSE.md",
        "CHANGELOG.md"
      ],
      formatters: ["html"],
      skip_undefined_reference_warnings_on: ["changelog", "CHANGELOG.md"]
    ]
  end
end
