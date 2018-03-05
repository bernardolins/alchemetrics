defmodule Alchemetrics.Dataset do
  use GenServer

  alias Alchemetrics.DatasetInfo

  def create(name) do
    case GenServer.start_link(__MODULE__, DatasetInfo.new(name), [name: name]) do
      {:ok, pid} ->
        {:ok, calculator_pid} = Alchemetrics.DatasetCalculator.start_link
        :timer.send_interval(:timer.seconds(1), pid, {:calculate_dataset, calculator_pid, name})
        :ok
      {:error, {:already_started, _}} ->
        :ok
      {:error, reason} ->
        {:error, reason}
    end
  end
  def init(dataset), do: {:ok, dataset}

  def add_value(name, value) do
    case create(name) do
      :ok -> GenServer.cast(name, {:add_value, value})
      {:error, reason} -> {:error, reason}
    end
  end
  def handle_cast({:add_value, value}, dataset), do: {:noreply, DatasetInfo.put_value(dataset, value)}

  def handle_info({:calculate_dataset, calculator_pid, name}, dataset) do
    Alchemetrics.DatasetCalculator.calculate(dataset, calculator_pid)
    {:noreply, DatasetInfo.new(name)}
  end
end
