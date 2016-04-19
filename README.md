# AtomicMap

A small helper to convert deep hashes with mixed string/atom keys to atom-only keyed maps. Optionally with a safe option, to prevent [atom space exhaustion of the Erlang VM](https://erlangcentral.org/wiki/index.php?title=String_Conversion_To_Atom).

## Usage


```elixir
iex> AtomicMap.convert(%{"a" => 2, "b" => %{"c" => 4}}, safe: true)
%{a: 2, b: %{c: 4}}
```




## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add atomic_map to your list of dependencies in `mix.exs`:

        def deps do
          [{:atomic_map, "~> 0.0.1"}]
        end

  2. Ensure atomic_map is started before your application:

        def application do
          [applications: [:atomic_map]]
        end

