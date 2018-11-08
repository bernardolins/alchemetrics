defmodule Alchemetrics.Registry.Group do
  @registry_default_opts [
    keys: :unique,
    name: __MODULE__,
    partitions: System.schedulers_online()
  ]

  def child_spec(_) do
    Registry.child_spec(@registry_default_opts)
  end

  def register(group_name, options \\ []) do
    case Registry.register(__MODULE__, group_name, options) do
      {:ok, _} -> :ok
      {:error, reason} -> {:error, reason}
    end
  end

  def lookup(group_name) do
    case Registry.lookup(__MODULE__, group_name) do
      [] -> {:error, :not_found}
      [{pid, opts}] -> {:ok, {pid, opts}}
    end
  end
end
