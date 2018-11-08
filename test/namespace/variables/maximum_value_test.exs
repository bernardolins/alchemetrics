defmodule Alchemetrics.Variable.MaximumValueTest do
  use ExUnit.Case

  test "the initial value is 0" do
    {:ok, var} = Alchemetrics.Variable.MaximumValue.create()
    assert 0 == Alchemetrics.Variable.current_value(var)
  end

  test "keeps only the greatest value of the events" do
    {:ok, var} = Alchemetrics.Variable.MaximumValue.create()
    assert 0 == Alchemetrics.Variable.current_value(var)
    Alchemetrics.Variable.new_event(var, %{value: 5})
    assert 5 == Alchemetrics.Variable.current_value(var)
    Alchemetrics.Variable.new_event(var, %{value: 20})
    assert 20 == Alchemetrics.Variable.current_value(var)
    Alchemetrics.Variable.new_event(var, %{value: 0})
    assert 20 == Alchemetrics.Variable.current_value(var)
  end

  test "reseting the variable sets the value to 0" do
    {:ok, var} = Alchemetrics.Variable.MaximumValue.create()
    assert 0 == Alchemetrics.Variable.current_value(var)
    Alchemetrics.Variable.new_event(var, %{value: 10})
    assert 10 == Alchemetrics.Variable.current_value(var)
    Alchemetrics.Variable.reset(var)
    assert 0 == Alchemetrics.Variable.current_value(var)
  end
end
