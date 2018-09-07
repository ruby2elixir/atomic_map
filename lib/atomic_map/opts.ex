defmodule AtomicMap.Opts do
  @moduledoc ~S"""
  Set any value to `false` to disable checking for that kind of key.
  """
  defstruct safe: true,
            underscore: true,
            ignore: false
end
