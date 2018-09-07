defmodule AtomicMap.Key do
  @moduledoc false

  alias AtomicMap.Opts

  @doc """
  The `convert_fn/2` returns a function that convert key into atom
  """
  @spec convert_fn(list(), Opts.t) :: (any() -> atom())
  def convert_fn(regex_patterns \\ [], %Opts{} = opts) do
    & &1
    |> as_regex_replace(regex_patterns)
    |> as_underscore(opts.underscore)
    |> as_atom(opts.safe, opts.ignore)
  end


  ## Private

  # params: key, safe, ignore
  defp as_atom(key, true, true) when is_binary(key) do
    try do
      as_atom(key, true, false)
    rescue
      ArgumentError -> key
    end
  end
  defp as_atom(key, true, false) when is_binary(key) do
    String.to_existing_atom(key)
  end
  defp as_atom(key, false, _) when is_binary(key) do
    String.to_atom(key)
  end
  defp as_atom(key, _, _), do: key

  # Underscore
  defp as_underscore(key, true) when is_number(key), do: key
  defp as_underscore(key, true) when is_binary(key) do
    do_underscore(key)
  end
  defp as_underscore(key, true) when is_atom(key) do
    key
    |> Atom.to_string()
    |> as_underscore(true)
  end
  defp as_underscore(key, false), do: key

  defp do_underscore(key) do
    key
    |> Macro.underscore()
    |> String.replace(~r/-/, "_")
  end

  # Custom replacement
  defp as_regex_replace(key, regex_patterns) do
    Enum.reduce(regex_patterns, key, & do_regex_replace/2)
  end

  defp do_regex_replace({pattern, replacement}, key) do
    Regex.replace(pattern, key, replacement)
  end
end
