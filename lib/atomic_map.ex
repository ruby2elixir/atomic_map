defmodule AtomicMap do
  def convert(map, opts) when is_map(map) do
    safe = Keyword.get(opts, :safe, true)
    map |> Enum.reduce(%{}, fn
       # convert strings to atoms
       {k,v}, acc when is_binary(k) and is_map(v)
           -> Map.put(acc, as_atom(k, safe), convert(v, opts));
       {k,v}, acc when is_map(v)
           -> Map.put(acc, k, convert(v, opts));
       {k,v}, acc when is_binary(k)
           -> Map.put(acc, as_atom(k, safe), v);
       {k,v}, acc
           -> Map.put(acc, k, v)
    end)
  end

  defp as_atom(s, true) when is_binary(s), do: s |> String.to_existing_atom
  defp as_atom(s, true),                   do: s

  defp as_atom(s, false) when is_binary(s), do: s |> String.to_atom
  defp as_atom(s, false),                   do: s
end
