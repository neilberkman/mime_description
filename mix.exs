defmodule MimeDescription.MixProject do
  @moduledoc false
  use Mix.Project

  @version "0.11.1"
  @url "https://github.com/neilberkman/mime_description"
  @maintainers ["Neil Berkman"]

  def project do
    [
      name: "MimeDescription",
      app: :mime_description,
      version: @version,
      elixir: "~> 1.15",
      package: package(),
      source_url: @url,
      maintainers: @maintainers,
      description: "Human-friendly MIME type descriptions for Elixir",
      homepage_url: @url,
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env()),
      docs: docs(),
      dialyzer: [
        ignore_warnings: ".dialyzer_ignore.exs",
        plt_add_apps: [:mix]
      ],
      start_permanent: Mix.env() == :prod
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :inets, :ssl]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:sweet_xml, "~> 0.7"},
      {:req, "~> 0.5"},
      {:jason, "~> 1.4.4"},
      {:castore, "~> 1.0.15"},
      {:finch, ">= 0.17.0"},

      # dev
      {:ex_doc, "~> 0.38.3", only: :dev},
      {:credo, "~> 1.0", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4.6", only: [:dev], runtime: false},
      {:mix_test_watch, "~> 1.0", only: :dev, runtime: false},
      {:quokka, "~> 2.11.2", only: [:dev, :test], runtime: false}
    ]
  end

  defp docs do
    [
      extras: [
        "README.md"
      ],
      main: "readme",
      source_ref: "v#{@version}",
      source_url: @url
    ]
  end

  defp package do
    [
      maintainers: @maintainers,
      licenses: ["MIT"],
      links: %{
        "GitHub" => @url
      },
      files: ~w(lib LICENSE mix.exs README.md)
    ]
  end
end
