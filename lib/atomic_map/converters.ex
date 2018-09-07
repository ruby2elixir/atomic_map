alias AtomicMap.Opts

defprotocol AtomicMap.Converters do
  @moduledoc """
  The `AtomicMap.Converters` protocol.
  """

  @doc """
  Convert
  """
  @spec convert(
    term        :: term(),
    convert_key :: (any(), Opts.t -> atom()),
    opts        :: Opts.t
  ) :: map()
  @fallback_to_any true
  def convert(term, convert_key, opts \\ %Opts{})
end


alias AtomicMap.Converters

defimpl AtomicMap.Converters, for: Map do
  def convert(%{__struct__: type} = term, convert_key, %Opts{} = opts) do
    term
    |> Map.from_struct()
    |> Converters.convert(convert_key, opts)
    |> Map.put(:__struct__, type)
  end

  def convert(term, convert_key, %Opts{} = opts) do
    Enum.reduce(term, %{}, fn {k, v}, acc ->
      key = convert_key.(k, opts)
      val = Converters.convert(v, convert_key, opts)

      Map.put(acc, key, val)
    end)
  end
end

defimpl AtomicMap.Converters, for: List do
  def convert(term, convert_key, %Opts{} = opts) do
    Enum.map(term, & Converters.convert(&1, convert_key, opts))
  end
end

defimpl AtomicMap.Converters, for: Tuple do
  def convert(term, convert_key, %Opts{} = opts) do
    term
    |> Tuple.to_list()
    |> Converters.convert(convert_key, opts)
    |> List.to_tuple()
  end
end

defimpl AtomicMap.Converters, for: Any do
  def convert(term, _, %Opts{}), do: term
end
