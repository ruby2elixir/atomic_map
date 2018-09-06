defmodule AtomicMap.Base do
  @moduledoc """
  Base module for AtomicMap.
  """

  @doc false
  @callback convert(data :: any(), opts :: AtomicMap.Opts.t) :: map()

  import Macro, only: [escape: 1]

  @doc false
  defmacro __using__(opts \\ []) do
    atomic_map_opts = struct(AtomicMap.Opts, opts)

    quote do
      def convert(v, opts \\ unquote(escape(atomic_map_opts)))

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

      defp as_underscore(s, true)  when is_number(s), do: s
      defp as_underscore(s, true)  when is_binary(s), do: s |> do_underscore()
      defp as_underscore(s, true)  when is_atom(s),   do: s |> Atom.to_string() |> as_underscore(true)
      defp as_underscore(s, false),                   do: s

      defp do_underscore(s) do
        s
        |> Macro.underscore()
        |> String.replace(~r/-/, "_")
      end
    end
  end
end
