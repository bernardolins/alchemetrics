defmodule Alchemetrics.Exometer.Group do
  @enforce_keys [:name]
  defstruct [:name, metadata_keys: [], measures: [:sum, :total_sum]]

  def start_link do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def create_group(%Alchemetrics.Exometer.Group{} = group) do
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

  def measures(name) do
    get_group(name)
    |> get_key(:measures)
  end

  def metadata_keys(name) do
    get_group(name)
    |> get_key(:metadata_keys)
  end

  defp get_key(nil, _), do: nil
  defp get_key(%__MODULE__{} = group, key), do: Map.get(group, key)
end
