defmodule Alchemetrics.Backends.Manager do
  @moduledoc false

  use GenServer

  def start_link, do: GenServer.start_link(__MODULE__, [], name: __MODULE__)

  def init(_) do
    started_backends =
      Application.get_env(:alchemetrics, :backends, [])
      |> Enum.map(fn({module, init_options}) ->
        module.start_link(init_options)
      end)
    {:ok, started_backends}
  end

  def set_enabled(module),  do: GenServer.cast(__MODULE__, {:enable_backend, module})
  def set_disabled(module), do: GenServer.cast(__MODULE__, {:disable_backend, module})
  def enabled_backends,     do: GenServer.call(__MODULE__, :enabled_backends)

  def handle_cast({:enable_backend, module}, enabled_backends), do: {:noreply, [module|enabled_backends]}
  def handle_cast({:disable_backend, module}, enabled_backends), do: {:noreply, List.delete(enabled_backends, module)}
  def handle_call(:enabled_backends, _, enabled_backends), do: {:reply, enabled_backends, enabled_backends}
end
