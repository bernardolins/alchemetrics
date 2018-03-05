defmodule Alchemetrics.DatasetInfo do
  defstruct [name: nil, max: nil, min: nil, size: 0, values: []]

  def new(name), do: %__MODULE__{name: name}

  def put_value(%__MODULE__{} = dataset_info, value) do
    %Alchemetrics.DatasetInfo{
      values: [value|dataset_info.values],
      size: dataset_info.size+1,
      max: choose_greatest(dataset_info.max, value),
      min: choose_smallest(dataset_info.min, value)
    }
  end

  defp choose_greatest(nil, new), do: new
  defp choose_greatest(current, new) when current >= new, do: current
  defp choose_greatest(_, new), do: new

  defp choose_smallest(nil, new), do: new
  defp choose_smallest(current, new) when current <= new, do: current
  defp choose_smallest(_, new), do: new
end
