defmodule Alchemetrics.Variable.EventCount do
  use Alchemetrics.Variable, initial_value: 0

  def update(_event, current), do: current+1
end
