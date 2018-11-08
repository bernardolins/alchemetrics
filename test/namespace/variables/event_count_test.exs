defmodule Alchemetrics.Variable.EventCountTest do
  use ExUnit.Case

  test "the initial value is 0" do
    {:ok, var} = Alchemetrics.Variable.EventCount.create()
    assert 0 == Alchemetrics.Variable.current_value(var)
  end

  test "a new event increments the value by 1" do
    {:ok, var} = Alchemetrics.Variable.EventCount.create()
    assert 0 == Alchemetrics.Variable.current_value(var)
    Alchemetrics.Variable.new_event(var, %{})
    assert 1 == Alchemetrics.Variable.current_value(var)
    Alchemetrics.Variable.new_event(var, %{})
    assert 2 == Alchemetrics.Variable.current_value(var)
  end

  test "reseting the variable sets the value to 0" do
    {:ok, var} = Alchemetrics.Variable.EventCount.create()
    assert 0 == Alchemetrics.Variable.current_value(var)
    Alchemetrics.Variable.new_event(var, %{})
    assert 1 == Alchemetrics.Variable.current_value(var)
    Alchemetrics.Variable.reset(var)
    assert 0 == Alchemetrics.Variable.current_value(var)
  end
end
