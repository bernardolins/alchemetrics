defmodule Alchemetrics.DatasetCalculator do
  use GenServer

  @percentile_list [:p99, :p95, :p75, :p50]
  @backend_list Application.get_env(:alchemetrics, :backends, [])

  def start_link do
    GenServer.start_link(__MODULE__, :nostate)
  end
  def calculate(%Alchemetrics.DatasetInfo{} = dataset, pid), do: GenServer.cast(pid, {:calculate_dataset, dataset})

  def init(:nostate), do: {:ok, :nostate}

  def handle_cast({:calculate_dataset, dataset}, :nostate) do
    d = Enum.sort(dataset.values)

    calculation_result = Enum.map(@percentile_list, fn(percentile) ->
      index = calculate_index(percentile, dataset.size)
      {percentile, Enum.at(d, index) || 0}
    end)
    |> Keyword.put(:max, dataset.max)
    |> Keyword.put(:min, dataset.min)
    |> Keyword.put(:size, dataset.size)
    |> Keyword.put(:name, dataset.name)

    Enum.each(@backend_list, fn({backend, _}) ->
      IO.inspect backend
      backend.do_report(calculation_result)
    end)

    {:noreply, :nostate}
  end

  defp calculate_index(:p99, size), do: ((size * 0.99) |> round) - 1
  defp calculate_index(:p95, size), do: ((size * 0.95) |> round) - 1
  defp calculate_index(:p75, size), do: ((size * 0.75) |> round) - 1
  defp calculate_index(:p50, size), do: ((size * 0.50) |> round) - 1
end
