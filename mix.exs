defmodule InquisitorJsonapi.Mixfile do
  use Mix.Project

  def project do
    [app: :inquisitor_jsonapi,
     version: "0.1.0",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     elixirc_paths: elixirc_paths(Mix.env),
     description: description(),
     package: package(),
     deps: deps(),
     docs: [
       extras: ["pages/Default\ Query\ Scopes.md"]
     ]]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: applications(Mix.env())]
  end

  defp description(), do: "JSON API Handlers for Inquisitor"

  defp package() do
    [maintainers: ["Brian Cardarella"],
     licenses: ["MIT"],
     links: %{"GitHub" => "https://github.com/DockYard/inquisitor_jsonapi"}
   ]
  end

  defp elixirc_paths(:test), do: elixirc_paths(:dev) |> Enum.concat(["test/support"])
  defp elixirc_paths(_), do: ["lib"]

  defp applications(:test), do: applications(:dev) |> Enum.concat([:postgrex])
  defp applications(_), do: [:logger, :inquisitor]

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [{:inquisitor, "~> 0.5.0"},
     {:ecto, "> 2.0.0"},
     {:plug, "~> 1.3.0", only: :test},
     {:earmark, "~> 0.1", only: :dev},
     {:ex_doc, "~> 0.11", only: :dev},
     {:postgrex, "> 0.0.0", only: :test}]
  end
end
