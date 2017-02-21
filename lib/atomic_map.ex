defmodule AtomicMap.Opts do
  @moduledoc ~S"""
  Set any value to `false` to disable checking for that kind of key.
  """
  defstruct safe: true,
            underscore: true
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
    |> as_underscore(opts.underscore)
    |> as_atom(opts.safe)
  end

  defp as_atom(s, true)  when is_binary(s) do
    try do
      s |> String.to_existing_atom()
    rescue
      ArgumentError -> s
    end
  end
  defp as_atom(s, false) when is_binary(s),  do: s |> String.to_atom()
  defp as_atom(s, _),                        do: s

  defp as_underscore(s, true)  when is_binary(s), do: s |> do_underscore()
  defp as_underscore(s, true)  when is_atom(s),   do: s |> Atom.to_string() |> as_underscore(true)
  defp as_underscore(s, false),                   do: s

  defp do_underscore(s) do
    s
    |> Macro.underscore()
    |> String.replace(~r/-/, "_")
  end
end
