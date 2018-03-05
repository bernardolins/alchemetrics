defmodule Alchemetrics.BackendStarter do
  @moduledoc false

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    backends = Application.get_env :alchemetrics, :backends, []
    backends
    |> Enum.each(fn({module, init_options}) ->
      module.start_link(init_options)
    end)
    {:ok, :added}
  end
end
