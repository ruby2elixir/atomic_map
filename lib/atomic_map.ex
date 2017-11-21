defmodule AtomicMap.Opts do
  @moduledoc ~S"""
  Set any value to `false` to disable checking for that kind of key.
  """
  defstruct safe: true,
            underscore: true,
            high_perf: false,
            ignore: false
end

defmodule AtomicMap do
  def convert(v, opts \\ %{})

  def convert(struct=%{__struct__: type}, opts=%AtomicMap.Opts{}) do
    struct
    |> Map.from_struct()
    |> convert(opts)
    |> Map.put(:__struct__, type)
  end
  def convert(map, opts=%AtomicMap.Opts{}) when is_map(map) do
    map |> Enum.reduce(%{}, fn({k,v}, acc)->
      k = k |> convert_key(opts)
      v = v |> convert(opts)
      acc |> Map.put(k, v)
    end)
  end
  def convert(list, opts=%AtomicMap.Opts{}) when is_list(list) do
    list |> Enum.map(fn(x)-> convert(x, opts) end)
  end
  def convert(tuple, opts=%AtomicMap.Opts{}) when is_tuple(tuple) do
    tuple |> Tuple.to_list |> convert(opts) |> List.to_tuple()
  end
  def convert(v, _opts=%AtomicMap.Opts{}),  do: v

  # if you pass a plain map or keyword list as opts, those will match and convert it to struct
  def convert(v, opts=%{}),                do: convert(v, struct(AtomicMap.Opts, opts))
  def convert(v, opts) when is_list(opts), do: convert(v, Enum.into(opts, %{}))

  defp convert_key(k, opts) do
    k
    |> as_underscore(opts.underscore, opts.high_perf)
    |> as_atom(opts.safe, opts.ignore)
  end

  # params: key, safe, ignore
  defp as_atom(s, true, true) when is_binary(s) do
    try do
      as_atom(s, true, false)
    rescue
      ArgumentError -> s
    end
  end
  defp as_atom(s, true, false) when is_binary(s) do
    s |> String.to_existing_atom()
  end
  defp as_atom(s, false, _) when is_binary(s),  do: s |> String.to_atom()
  defp as_atom(s, _, _),                        do: s

  defp as_underscore(s, true, false) when is_binary(s), do: s |> underscore()
  defp as_underscore(s, true, false) when is_atom(s), do: s |> Atom.to_string() |> as_underscore(true, false)
  defp as_underscore(s, true, true) when is_binary(s), do: s |> high_perf_underscore()
  defp as_underscore(s, true, true) when is_atom(s), do: s |> Atom.to_string() |> as_underscore(true, true)
  defp as_underscore(s, false, _), do: s

  defp underscore(s) when is_binary(s) do
    s |> Macro.underscore() |> String.replace("-", "_")
  end

  defp high_perf_underscore(s) when is_binary(s) do
    s |> String.to_charlist() |> high_perf_underscore() |> to_string()
  end
  defp high_perf_underscore([h | rest]) do
    [to_lower_char(h)] ++ to_underscore(rest, h)
  end
  defp high_perf_underscore('') do
    ''
  end

  defp to_underscore([h | rest], prev) when prev == ?_ or prev == ?- do
    [to_lower_char(h)] ++ to_underscore(rest, h)
  end
  defp to_underscore([h0, h1 | rest], _) when h0 >= ?A and h0 <= ?Z and not (h1 >= ?A and h1 <= ?Z) and h1 != ?_ and h1 != ?- do
    [?_, to_lower_char(h0), h1] ++ to_underscore(rest, h1)
  end
  defp to_underscore([h | rest], prev) when h >= ?A and h <= ?Z and not (prev >= ?A and prev <= ?Z) and prev != ?_ and prev != ?- do
    [?_, to_lower_char(h)] ++ to_underscore(rest, h)
  end
  defp to_underscore([h | rest], _) do
    [to_lower_char(h)] ++ to_underscore(rest, h)
  end
  defp to_underscore('', _) do
    ''
  end

  defp to_lower_char(?-), do: ?_
  defp to_lower_char(char) when char >= ?A and char <= ?Z, do: char + 32
  defp to_lower_char(char), do: char
end
