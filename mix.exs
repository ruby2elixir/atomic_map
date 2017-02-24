defmodule AtomicMap.Mixfile do
  use Mix.Project

  @version  "0.9.1"
  def project do
    [app: :atomic_map,
     version: @version,
     elixir: ">= 1.3.0",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     package: package(),
     docs: [extras: ["README.md"]],
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger]]
  end

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
    [
      {:earmark, "~> 1.1", only: :dev},
      {:ex_doc, "~> 0.14", only: :dev},
      {:benchfella, "~> 0.3", only: :dev},
    ]
  end

  defp package do
    [
     maintainers: ["Roman Heinrich"],
     licenses: ["MIT License"],
     description: "A small utility to convert deep Elixir maps with mixed string/atom keys to atom-only keyed maps",
     links: %{
       github: "https://github.com/ruby2elixir/atomic_map",
       docs: "http://hexdocs.pm/atomic_map/#{@version}/"
     }
    ]
  end
end
