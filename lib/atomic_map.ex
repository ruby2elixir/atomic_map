defmodule AtomicMap do

  def convert(map, opts) when is_map(map) do
    safe = Keyword.get(opts, :safe, true)
    map |> Enum.reduce(%{}, fn({k,v}, acc)->
       if is_binary(k), do: k = as_atom(k, safe)
       cond do
          is_complex?(v) -> Map.put(acc, k, convert(v, opts));
          true           -> Map.put(acc, k, v)
      end
    end)
  end
  def convert(list, opts) when is_list(list) do
    list |> Enum.map(fn(x)-> convert(x, opts) end)
  end
  def convert(v, opts),  do: v

  defp is_complex?(v), do: is_map(v) || is_list(v)
  defp as_atom(s, true) when is_binary(s), do: s |> String.to_existing_atom
  defp as_atom(s, true),                   do: s

  defp as_atom(s, false) when is_binary(s), do: s |> String.to_atom
  defp as_atom(s, false),                   do: s
end
