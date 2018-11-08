defmodule Alchemetrics.Namespace do
  use Agent

  defstruct [
    variables: [],
    sampling: nil,
  ]

  def start_link(namespace, opts \\ []) do
    ns = struct(__MODULE__, opts)
    Agent.start_link(fn -> ns end, name: namespace)
  end

  def info(namespace), do: Agent.get(namespace, &(&1))
end
