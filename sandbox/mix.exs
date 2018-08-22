defmodule PlaygroundElixir.Mixfile do
  use Mix.Project

  def project do
    [
      app: :playground_elixir,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      elixirc_paths: elixirc_paths(Mix.env),
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
      {:gen_stage, "~> 0.12.1"},
      {:poison,    "~> 3.1"},
      {:httpotion, "~> 3.0"},
      {:plug,      "~> 1.4.0"}
    ]
  end

  defp elixirc_paths(:test) do
    ["lib", "test/support"]
  end
  defp elixirc_paths(_) do
    ["lib"]
  end
end
