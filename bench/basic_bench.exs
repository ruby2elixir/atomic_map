defmodule BasicBench do
  use Benchfella

  def macro_underscore(s) do
    s
    |> Macro.underscore
    |> String.replace(~r/-/, "_")
  end

  def regex_underscore(s) do
    s
    |> String.replace(~r/([A-Z]+)([A-Z][a-z])/, "\\1_\\2")
    |> String.replace(~r/([a-z\d])([A-Z])/, "\\1_\\2")
    |> String.replace(~r/-/, "_")
    |> String.downcase
  end

  @long_string "StringShouldChange-some_stuffStringShouldChange-some_stuffStringShouldChange-some_stuffStringShouldChange-some_stuffStringShouldChange-some_stuff"
  @short_string "StringShouldChange-some_stuff"

  @payload_camel_cased File.read!("bench/test-payload-camel-cased.json") |> Poison.decode!()
  @large_payload_camel_cased 1..100 |> Enum.reduce(%{}, fn(x, acc) -> Map.put(acc, "key#{x}", @payload_camel_cased) end)

  @payload_snake_cased File.read!("bench/test-payload-camel-cased.json") |> Poison.decode!()
  @large_payload_snake_cased 1..100 |> Enum.reduce(%{}, fn(x, acc) -> Map.put(acc, "key#{x}", @payload_snake_cased) end)

  bench "macro_underscore - long" do
    @long_string |> macro_underscore
  end

  bench "regex_underscore - long" do
    @long_string |> regex_underscore
  end

  bench "macro_underscore - short" do
    @short_string |> macro_underscore
  end

  bench "regex_underscore - short" do
    @short_string |> regex_underscore
  end

  bench "large dict camel cased with low perf underscore" do
    @large_payload_camel_cased |> AtomicMap.convert(safe: false, underscore: true, high_perf: false)
  end

  bench "large dict camel cased with high perf underscore" do
    @large_payload_camel_cased |> AtomicMap.convert(safe: false, underscore: true, high_perf: true)
  end

  bench "large dict snake cased with low perf underscore" do
    @large_payload_snake_cased |> AtomicMap.convert(safe: false, underscore: true, high_perf: false)
  end

  bench "large dict snake cased with high perf underscore" do
    @large_payload_snake_cased |> AtomicMap.convert(safe: false, underscore: true, high_perf: true)
  end
end
