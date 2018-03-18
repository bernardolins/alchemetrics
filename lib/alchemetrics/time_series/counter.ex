defmodule Alchemetrics.TimeSeries.Counter do
  use GenServer

  def start_link do
    case GenServer.start_link(__MODULE__, []) do
      {:ok, pid} ->
        :timer.send_interval(:timer.seconds(10), pid, :report)
        {:ok, pid}
      {:error, reason} ->
        {:error, reason}
    end
  end
  def init(counter), do: {:ok, counter}

  def increment_by(delta, labels) do
    pid = pid_for_labels(labels)
    GenServer.cast(pid, {:increment_by, delta, labels})
  end
  def handle_cast({:increment_by, delta, labels}, counter) do
    total = Keyword.get(counter, :total, 0)
    last_interval = Keyword.get(counter, :last_interval, 0)

    {:noreply, [total: total+delta, last_interval: last_interval+delta, labels: labels]}
  end

  def handle_info(:report, counter) do
    total = Keyword.get(counter, :total, 0)

    Alchemetrics.Backends.Manager.enabled_backends
    |> Enum.each(fn(module) -> module.do_report(counter) end)

    {:noreply, [total: total]}
  end

  defp pid_for_labels(labels) do
    case :ets.lookup(:counter_pids, labels) do
      [{_, pid}] ->
        pid
      [] ->
        {:ok, pid} = start_link()
        :ets.insert(:counter_pids, {labels, pid})
        pid
    end
  end
end
