defmodule Alchemetrics.Group do
  @moduledoc false

  use GenStage

  alias Alchemetrics.Group.Buffer

  def create(group_name, opts \\ []), do: GenStage.start_link(__MODULE__, {group_name, opts})

  def init({group_name, opts}) do
    case Alchemetrics.Registry.Group.register(group_name, opts) do
      :ok -> {:producer, Buffer.new(), dispatcher: GenStage.BroadcastDispatcher}
      {:error, reason} -> {:stop, reason}
    end
  end

  def publish(group_name, message) do
    case Alchemetrics.Registry.Group.lookup(group_name) do
      {:ok, {pid, _}} -> GenStage.cast(pid, {:publish, message})
      {:error, :not_found} -> {:error, :group_not_found}
    end
  end

  def join(group_name, client) do
    with {:ok, {group, _}} <- Alchemetrics.Registry.Group.lookup(group_name),
         {:ok, _} <- GenStage.sync_subscribe(client, to: group, group_name: group_name)
    do
      :ok
    else
      error -> error
    end
  end

  def handle_cast({:publish, message}, %Buffer{} = state) do
    store_message(state, message)
  end

  def handle_demand(incoming_demand, %Buffer{} = state) do
    change_demand_by(state, incoming_demand)
  end

  defp store_message(%Buffer{} = state, message) do
    state
    |> Buffer.buffer_message(message)
    |> dispatch_messages
  end

  defp change_demand_by(%Buffer{} = state, demand_delta) when is_integer(demand_delta) do
    state
    |> Buffer.update_demand(demand_delta)
    |> dispatch_messages
  end

  defp dispatch_messages(state, message_list \\ [])
  defp dispatch_messages(%Buffer{demand: 0} = state, message_list), do: {:noreply, message_list, state}
  defp dispatch_messages(%Buffer{} = state, message_list) do
    case Buffer.next_message(state) do
      {:empty, new_state} -> {:noreply, message_list, new_state}
      {:ok, message, new_state} ->
        updated_state = Buffer.update_demand(new_state, -1)
        dispatch_messages(updated_state, [message|message_list])
    end
  end
end
