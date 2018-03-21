# AtomicMap

[![Build status](https://travis-ci.org/ruby2elixir/atomic_map.svg "Build status")](https://travis-ci.org/ruby2elixir/atomic_map)
[![Hex version](https://img.shields.io/hexpm/v/atomic_map.svg "Hex version")](https://hex.pm/packages/atomic_map)
![Hex downloads](https://img.shields.io/hexpm/dt/atomic_map.svg "Hex downloads")


A small utility to convert Elixir maps with mixed string/atom keys to atom-only keyed maps. Optionally with a safe option, to prevent [atom space exhaustion of the Erlang VM](https://erlangcentral.org/wiki/index.php?title=String_Conversion_To_Atom). Since v0.8 it also supports conversion of keys from `CamelCase` to `under_score` format.

AtomicMap can convert simple maps or nested structures such as lists of maps; see [Nested Structures](#nested-structures) below for examples.

## Usage

### Safety

With no options, it safely converts string keys in maps to atoms, using [`String.to_existing_atom/1`](https://hexdocs.pm/elixir/String.html#to_existing_atom/1).

```elixir
iex> AtomicMap.convert(%{"a" => "a", "b" => "b", c: "c"})
%{a: "a", b: "b", c: "c"}
```

Because safe conversion uses [`String.to_existing_atom/1`](https://hexdocs.pm/elixir/String.html#to_existing_atom/1), it will raise when the target atom does not exist.

```elixir
iex> AtomicMap.convert(%{"abcdefg" => "a", "b" => "b"})
** (ArgumentError) argument error
    :erlang.binary_to_existing_atom("abcdefg", :utf8)
```

To have safe conversion can ignore unsafe keys, leaving them as strings, pass `true` for the `ignore` option.

```elixir
iex> AtomicMap.convert(%{"abcdefg" => "a", "b" => "b"}, %{ignore: true})
%{:b => "b", "abcdefg" => "a"}
```

To disable safe conversion and allow new atoms to be created, pass `false` for the `safe:` option.
(This makes the `ignore` option irrelevant.)
If the input is user-generated, converting only expected keys will prevent excessive atom creation.

```elixir
iex> map = %{"expected_key" => "a", "b" => "b", "unexpected_key" => "c"}
%{"expected_key" => "a", "b" => "b", "unexpected_key" => "c"}

iex> filtered_map = Map.take(map, ["expected_key", "b"])
%{"b" => "b", "expected_key" => "a"}

iex> AtomicMap.convert(filtered_map, %{safe: false})
%{b: "b", expected_key: "a"}
```

### Underscoring

By default, `"CamelCase"` string keys will be converted to `under_score` atom keys.

```
iex> AtomicMap.convert(%{ "CamelCase" => "hi" })
** (ArgumentError) argument error
    :erlang.binary_to_existing_atom("camel_case", :utf8)
```

Note that `"camel_case"` was the string that failed conversion.
If that atom is explicitly created first, the conversion will succeed.

```elixir
iex> :camel_case
:camel_case
iex> AtomicMap.convert(%{ "CamelCase" => "hi" })
%{camel_case: "hi"}
```

Allowing unsafe conversions will also work.
If the input is user-generated, converting only expected keys will prevent excessive atom creation.

```elixir
iex> map = %{"CamelCase" => "a", "b" => "b", "AnotherCamelCase" => "c"}
%{"CamelCase" => "a", "b" => "b", "AnotherCamelCase" => "c"}

iex> filtered_map = Map.take(map, ["CamelCase", "b"])
%{"b" => "b", "CamelCase" => "a"}

iex> AtomicMap.convert(filtered_map, %{safe: false})
%{b: "b", camel_case: "a"}
```

### Replacing Hyphens

`"hyphenated-string"` keys will always be converted to `under_score` atom keys.
There is currently no way to disable this behavior.

```elixir
iex> AtomicMap.convert(%{"some-key" => "a", "b" => "c"})
** (ArgumentError) argument error
    :erlang.binary_to_existing_atom("some_key", :utf8)
```

Note that `"some_key"` was the string that failed conversion.
If that atom is explicitly created first, the conversion will succeed.

```elixir
iex> :some_key
:some_key

iex> AtomicMap.convert(%{"some-key" => "a", "b" => "c"})
%{b: "c", some_key: "a"}
```

Allowing unsafe conversions will also work.
If the input is user-generated, converting only expected keys will prevent excessive atom creation.

```elixir
iex> map = %{"some-key" => "a", "b" => "b", "another-key" => "c"}
%{"some-key" => "a", "b" => "b", "another-key" => "c"}

iex> filtered_map = Map.take(map, ["some-key", "b"])
%{"b" => "b", "some-key" => "a"}

iex> AtomicMap.convert(filtered_map, %{safe: false})
%{b: "b", some_key: "a"}
```

### Nested Structures

```elixir
# works with nested maps
iex> AtomicMap.convert(%{"a" => 2, "b" => %{"c" => 4}})
%{a: 2, b: %{c: 4}}

# works with nested maps + lists + mixed key types (atoms + binaries)
iex> AtomicMap.convert([ %{"c" => 1}, %{:c => 2}, %{"c" => %{:b => 4}}], %{safe: true})
[%{c: 1}, %{c: 2}, %{c: %{b: 4}}]
```

## Installation
  1. Add atomic_map to your list of dependencies in `mix.exs`:

        def deps do
          [{:atomic_map, "~> 0.8"}]
        end

## Todo:
  - maybe allow direct conversion to a struct, like Poison does it: as: %SomeStruct{}...


## Benchmark

    $ mix bench
