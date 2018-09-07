defmodule AtomicMap.Base do
  @moduledoc """
  Base module for AtomicMap.
  """

  import Macro, only: [escape: 1]
  alias AtomicMap.{Key, Opts}

  @doc false
  @callback convert(data :: any(), opts :: Opts.t) :: map()

  @doc false
  defmacro __using__(opts \\ []) do
    atomic_map_opts = struct(Opts, opts)

    quote do
      Module.register_attribute(__MODULE__, :regex_patterns, [accumulate: true])

      @before_compile AtomicMap.Base

      import AtomicMap.Base, only: [replace: 2]
      alias AtomicMap.Converters


      def convert(term, opts \\ unquote(escape(atomic_map_opts)))
      def convert(term, %Opts{} = opts) do
        conver_key_fn = Key.convert_fn(__MODULE__.__regex_patterns__(), opts)
        Converters.convert(term, conver_key_fn)
      end
      def convert(term, %{} = opts) do
        convert(term, struct(Opts, opts))
      end
      def convert(term, opts) when is_list(opts) do
        convert(term, Enum.into(opts, %{}))
      end
    end
  end

  defmacro __before_compile__ _ do
    quote do
      def __regex_patterns__, do: @regex_patterns
    end
  end

  defmacro replace(pattern, replacement) do
    quote do
      Module.put_attribute __MODULE__, :regex_patterns,
        {unquote(pattern), unquote(replacement)}
    end
  end
end
