defmodule AtomicMap.Base do
  @moduledoc """
  Base module for AtomicMap.
  """

  import Macro, only: [escape: 1]
  alias AtomicMap.Opts

  @doc false
  @callback convert(data :: any(), opts :: Opts.t) :: map()

  @doc false
  defmacro __using__(opts \\ []) do
    atomic_map_opts = struct(Opts, opts)

    quote do
      import AtomicMap.Converters, only: [convert: 3]

      def convert(term, opts \\ unquote(escape(atomic_map_opts)))
      def convert(term, %Opts{} = opts) do
        convert(term, & convert_key/2, opts)
      end
      def convert(term, %{} = opts) do
        convert(term, struct(Opts, opts))
      end
      def convert(term, opts) when is_list(opts) do
        convert(term, Enum.into(opts, %{}))
      end

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
