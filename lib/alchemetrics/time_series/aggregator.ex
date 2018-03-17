defmodule Alchemetrics.TimeSeries.Aggregator do
  use GenServer

  @percentile_list [:p99, :p95, :p75, :p50]

  def start_link(_), do: GenServer.start_link(__MODULE__, :nostate)
  def init(:nostate), do: {:ok, :nostate}

  def aggregate(dataset, pid) do
    GenServer.cast(pid, {:aggregate, dataset})
  end
  def handle_cast({:aggregate, dataset}, :nostate) do
    time_series = Enum.group_by(dataset, fn(data) -> data[:labels] end, fn(data) -> data[:value] end)

    Enum.each(time_series, fn({labels, values}) ->
      size = length(values)
      d = Enum.sort(values)

      calculation_result = Enum.map(@percentile_list, fn(percentile) ->
        index = calculate_index(percentile, size)
        {percentile, Enum.at(d, index) || 0}
      end)
      |> Keyword.put(:max, Enum.max(values))
      |> Keyword.put(:min, Enum.min(values))
      |> Keyword.put(:size, size)
      |> Keyword.put(:labels, labels)

      Alchemetrics.Backends.Manager.enabled_backends
      |> Enum.each(fn(module) -> module.do_report(calculation_result) end)
    end)

    {:noreply, :nostate}
  end

  defp calculate_index(:p99, size), do: ((size * 0.99) |> round) - 1
  defp calculate_index(:p95, size), do: ((size * 0.95) |> round) - 1
  defp calculate_index(:p75, size), do: ((size * 0.75) |> round) - 1
  defp calculate_index(:p50, size), do: ((size * 0.50) |> round) - 1
end
