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
end
