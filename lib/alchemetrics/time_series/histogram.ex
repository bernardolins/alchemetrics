defmodule Alchemetrics.TimeSeries.Histogram do
  use GenServer

  def start_link do
    case GenServer.start_link(__MODULE__, []) do
      {:ok, pid} ->
        :timer.send_interval(:timer.seconds(10), pid, {:aggregate_dataset})
        {:ok, pid}
      {:error, reason} ->
        {:error, reason}
    end
  end
  def init(dataset), do: {:ok, dataset}

  def store_metric(%{labels: labels, value: _} = metric) do
    pid = pid_for_labels(labels)
    GenServer.cast(pid, {:store_metric, metric})
  end
  def handle_cast({:store_metric, metric}, dataset), do: {:noreply, [metric | dataset]}

  def handle_info({:aggregate_dataset}, dataset) do
    call_aggregator(dataset)
    {:noreply, []}
  end

  defp pid_for_labels(labels) do
    case :ets.lookup(:histogram_pids, labels) do
      [{_, pid}] ->
        pid
      [] ->
        {:ok, pid} = start_link()
        :ets.insert(:histogram_pids, {labels, pid})
    end
  end

  defp call_aggregator(dataset) do
    :poolboy.transaction(
      :aggregator,
      fn(pid) ->
        Alchemetrics.TimeSeries.Aggregator.aggregate(dataset, pid)
      end)
  end
end
