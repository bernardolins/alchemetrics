defmodule Alchemetrics.GroupAgent do
  def start_link do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def create_group(%Alchemetrics.Group{} = group) do
    Agent.update(__MODULE__, &Map.put_new(&1, group.name, group))
  end

  def set(name, key, value) do
    group = get_group(name)
    |> Map.put(key, value)
    Agent.update(__MODULE__, &Map.put(&1, name, group))
  end

  def get_group(name) do
    Agent.get(__MODULE__, &Map.get(&1, name))
  end
end
