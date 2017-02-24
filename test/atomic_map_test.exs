defmodule AtomicMapTest do
  use ExUnit.Case
  doctest AtomicMap

  defmodule MyStruct do
    defstruct first: nil, second: nil
  end

  test "works with maps" do
    input    = %{"a" => 2, "b" => %{"c" => 4}}
    expected = %{a: 2, b: %{c: 4}}
    assert AtomicMap.convert(input, %{safe: true}) == expected
  end

  test "works with maps with lists" do
    input    = %{ "a" => [ %{"c" => 1}, %{"c" => 2}] }
    expected = %{a: [%{c: 1}, %{c: 2}] }
    assert AtomicMap.convert(input, safe: true) == expected
  end

  test "works with lists with maps" do
    input    = [ %{"c" => 1}, %{"c" => 2}, %{"c" => %{"b" => 4}}]
    expected = [%{c: 1}, %{c: 2}, %{c: %{b: 4}}]
    assert AtomicMap.convert(input, safe: true) == expected
  end

  test "works with mixed keys (string / atoms)" do
    input    = [ %{"c" => 1}, %{:c => 2}, %{"c" => %{:b => 4}}]
    expected = [%{c: 1}, %{c: 2}, %{c: %{b: 4}}]
    assert AtomicMap.convert(input, safe: true) == expected
  end

  test "works with simple values" do
    input    = "2"
    expected = "2"
    assert AtomicMap.convert(input, safe: true) == expected
  end

  test "works with default opts" do
    input    = "2"
    expected = "2"
    assert AtomicMap.convert(input) == expected
  end

  test "works with structs" do
    input    = %AtomicMapTest.MyStruct{first: [%{"a" => 1}]}
    expected = %AtomicMapTest.MyStruct{first: [%{a: 1}]}
    assert AtomicMap.convert(input) == expected
  end

  test "works with nested structs" do
    input    = %AtomicMapTest.MyStruct{first: [%AtomicMapTest.MyStruct{first: %{"b" => 1}}]}
    expected = %AtomicMapTest.MyStruct{first: [%AtomicMapTest.MyStruct{first: %{b: 1}}]}
    assert AtomicMap.convert(input) == expected
  end

  test "works with tuples" do
    input    = %{ "first"  => {1,2}}
    expected = %{first: {1, 2}}
    assert AtomicMap.convert(input) == expected
  end

  test "converts keys to underscore by default (attention: safe: false needed here)" do
    input    = %{ "firstKey"  => {1,2}, :secondKey => 4}
    expected = %{first_key: {1, 2}, second_key: 4}
    assert AtomicMap.convert(input, safe: false) == expected
  end

  test "underscore flag works with hyphens" do
    input    = %{ "first-key"  => {1,2}}
    expected = %{first_key: {1, 2}}
    assert AtomicMap.convert(input, safe: false) == expected
  end

  test "skips not existing atoms when ignore = true" do
    input    = %{"unknow_val" => 2}
    expected = %{"unknow_val" => 2}
    assert AtomicMap.convert(input, %{safe: true, ignore: true}) == expected
  end

  test "raises for not existing atoms when safe = true  and ignore = false" do
    assert_raise ArgumentError, fn ->
      input = %{"a" => 2, "b" => %{"c" => 4}, "__not___existing__" => 5}
      AtomicMap.convert(input, safe: true, ignore: false)
    end
  end
end
