defmodule Alchemetrics.Variable.MaximumValue do
  use Alchemetrics.Variable, initial_value: 0

  def update(%{value: value}, current) when current > value, do: current
  def update(%{value: value}, _current), do: value
end
