defmodule AtomicMap do
  def convert(v, opts \\ [])

  def convert(struct=%{__struct__: type}, opts) do
    struct
    |> Map.from_struct
    |> convert(opts)
    |> Map.put(:__struct__, type)
  end

  def convert(map, opts) when is_map(map) do
    safe = Keyword.get(opts, :safe, true)
    map |> Enum.reduce(%{}, fn({k,v}, acc)->
      k = as_atom(k, safe)
      v = convert(v, opts)
      acc |> Map.put(k, v)
    end)
  end
  def convert(list, opts) when is_list(list) do
    list |> Enum.map(fn(x)-> convert(x, opts) end)
  end
  def convert(v, _opts),  do: v
  defp as_atom(s, true) when is_binary(s), do: s |> String.to_existing_atom
  defp as_atom(s, true),                   do: s

  defp as_atom(s, false) when is_binary(s), do: s |> String.to_atom
  defp as_atom(s, false),                   do: s
end
