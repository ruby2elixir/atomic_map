# AtomicMap

[![Build status](https://travis-ci.org/ruby2elixir/atomic_map.svg "Build status")](https://travis-ci.org/ruby2elixir/atomic_map)
[![Hex version](https://img.shields.io/hexpm/v/atomic_map.svg "Hex version")](https://hex.pm/packages/atomic_map)
![Hex downloads](https://img.shields.io/hexpm/dt/atomic_map.svg "Hex downloads")


A small utility to convert deep Elixir maps with mixed string/atom keys to atom-only keyed maps. Optionally with a safe option, to prevent [atom space exhaustion of the Erlang VM](https://erlangcentral.org/wiki/index.php?title=String_Conversion_To_Atom). Since v0.8 it also supports conversion of keys from `CamelCase` to `under_score` format.

## Usage


```elixir
# works with nested maps
iex> AtomicMap.convert(%{"a" => 2, "b" => %{"c" => 4}}, safe: true)
%{a: 2, b: %{c: 4}}

# works with nested maps + lists + mixed key types (atoms + binaries)
iex> AtomicMap.convert([ %{"c" => 1}, %{:c => 2}, %{"c" => %{:b => 4}}], safe: true]
[%{c: 1}, %{c: 2}, %{c: %{b: 4}}]

# converts CamelCase to under_score by default (notice that you might have to turn 'safe' flag off)
iex> AtomicMap.convert(%{ "CamelCase" => [ %{"c" => 1}, %{"c" => 2}] }, safe: false)
%{camel_case: [%{c: 1}, %{c: 2}]}

# underscoring can be turned off by passing `underscore: false` to opts
iex> AtomicMap.convert(%{ "CamelCase" => [ %{"c" => 1}, %{"c" => 2}] }, safe: false, underscore: false )
%{CamelCase: [%{c: 1}, %{c: 2}]}
```


## Installation
  1. Add atomic_map to your list of dependencies in `mix.exs`:

        def deps do
          [{:atomic_map, "~> 0.8"}]
        end

## Todo:
  - maybe allow direct conversion to a struct, like Poison does it: as: %SomeStruct{}...
