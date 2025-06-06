defmodule ThousandIslandTailscale.MixProject do
  use Mix.Project

  def project do
    [
      app: :thousand_island_tailscale,
      version: "0.1.0",
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps()
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
      {:gen_tailscale, git: "https://github.com/Munksgaard/gen_tailscale.git"},
      {:plug, "~> 1.15"},
      {:req, "~> 0.5"},

      # Testing and development deps
      {:phoenix_playground, "~> 0.1.7", only: [:dev, :test]},
      {:req, "~> 0.5", only: [:dev, :test]}
    ]
  end
end
