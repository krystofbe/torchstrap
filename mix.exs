defmodule Torch.MixProject do
  use Mix.Project

  def project do
    [
      app: :torchstrap,
      version: "2.0.0-rc.1",
      elixir: "~> 1.5",
      start_permanent: Mix.env() == :prod,
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      name: "Torch",
      description: "Rapid admin generator with bootstrap styles included for Phoenix",
      source_url: "https://github.com/krystofbe/torchstrap",
      homepage_url: "https://github.com/krystofbe/torchstrap",
      test_paths: ["test/mix", "test/torchstrap"],
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ],
      elixirc_paths: elixirc_paths(Mix.env()),
      package: package(),
      docs: docs(),
      deps: deps()
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support/cases"]
  defp elixirc_paths(_env), do: ["lib"]

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:credo, "~> 0.5", only: [:dev, :test]},
      {:ex_doc, ">= 0.0.0", only: [:dev, :test]},
      {:excoveralls, ">= 0.0.0", only: [:dev, :test]},
      {:postgrex, ">= 0.0.0-rc"},
      {:filtrex, "~> 0.4.3"},
      {:gettext, "~> 0.16"},
      {:jason, "~> 1.0"},
      {:phoenix_html, "~> 2.10"},
      {:phoenix, "~> 1.4"},
      {:scrivener_ecto, "~> 2.0"},
      {:timex, "~> 3.1"}
    ]
  end

  defp package do
    [
      maintainers: ["Krystof Beuermann"],
      licenses: ["MIT"],
      links: %{
        "Github" => "https://github.com/krystofbe/torchstrap"
      },
      files: ~w(lib priv mix.exs README.md)
    ]
  end

  defp docs do
    [
      main: "readme",
      extras: ["README.md"]
    ]
  end
end
