defmodule AtomicMapTest do
  use ExUnit.Case
  doctest AtomicMap

  test "works with maps" do
    input    = %{"a" => 2, "b" => %{"c" => 4}}
    expected = %{a: 2, b: %{c: 4}}
    assert AtomicMap.convert(input, safe: true) == expected
  end

  test "raises for not existing atoms" do
    assert_raise ArgumentError, fn ->
      input = %{"a" => 2, "b" => %{"c" => 4}, "__not___existing__" => 5}
      AtomicMap.convert(input, safe: true)
    end
  end
end
