defmodule Alchemetrics.Backends.Manager do
  @moduledoc false

  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init([]) do
    started_backends =
      Application.get_env(:alchemetrics, :backends, [])
      |> Enum.map(fn({module, init_options}) ->
        module.enable(init_options)
        module
      end)
    {:ok, started_backends}
  end

  def enabled_backends, do: GenServer.call(__MODULE__, :enabled_backends)
  def handle_call(:enabled_backends, _, enabled_backends), do: {:reply, enabled_backends, enabled_backends}
end
