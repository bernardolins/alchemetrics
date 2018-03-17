defmodule Alchemetrics.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(Alchemetrics.Backends.Manager, []),
      worker(Alchemetrics.Predefined.Beam, []),
      worker(Alchemetrics.Producer, []),
      worker(Alchemetrics.Consumer, []),
      :poolboy.child_spec(:worker, poolboy_config())
    ]

    :ets.new(:time_series_manager_pids, [:named_table, :public])

    opts = [strategy: :one_for_one, name: Alchemetrics.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp poolboy_config do
    [
      {:name, {:local, :aggregator}},
      {:worker_module, Alchemetrics.TimeSeries.Aggregator},
      {:size, 10},
      {:max_overflow, 10}
    ]
  end
end
