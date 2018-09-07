defprotocol AtomicMap.Converters do
  @moduledoc """
  The `AtomicMap.Converters` protocol.
  """

  @doc """
  Convert
  """
  @spec convert(
    term           :: term(),
    convert_key_fn :: (any() -> atom())
  ) :: map()
  @fallback_to_any true
  def convert(term, convert_key_fn)
end


alias AtomicMap.Converters

defimpl AtomicMap.Converters, for: Map do
  def convert(term, convert_key_fn) do
    Enum.reduce(term, %{}, fn {k, v}, acc ->
      key = convert_key_fn.(k)
      val = Converters.convert(v, convert_key_fn)

      Map.put(acc, key, val)
    end)
  end
end

defimpl AtomicMap.Converters, for: List do
  def convert(term, convert_key_fn) do
    Enum.map(term, & Converters.convert(&1, convert_key_fn))
  end
end

defimpl AtomicMap.Converters, for: Tuple do
  def convert(term, convert_key_fn) do
    term
    |> Tuple.to_list()
    |> Converters.convert(convert_key_fn)
    |> List.to_tuple()
  end
end

defimpl AtomicMap.Converters, for: Any do
  def convert(%{__struct__: type} = term, convert_key_fn) do
    term
    |> Map.from_struct()
    |> Converters.convert(convert_key_fn)
    |> Map.put(:__struct__, type)
  end

  def convert(term, _), do: term
end
