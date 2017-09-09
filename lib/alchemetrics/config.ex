defmodule Alchemetrics.Config do
  alias Alchemetrics.Group
  alias Alchemetrics.GroupAgent

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    case Application.get_env(:alchemetrics, :config_agent) do
      nil -> nil
      config_agent -> config_agent.load
    end
    {:ok, :loaded}
  end

  defmacro __using__(_) do
    quote do
      import Alchemetrics.Config
      Application.put_env(:alchemetrics, :config_agent, __MODULE__)
      def load()
      defoverridable [load: 0]
    end
  end

  defmacro group(group_name, do: block) do
    quote do
      GroupAgent.create_group(%Group{name: unquote(group_name)})

      var!(group_name, Alchemetrics.Config) = unquote(group_name)
      unquote(block)
    end
  end

  defmacro set(key, value) do
    quote do
      group_name = var!(group_name, Alchemetrics.Config)
      GroupAgent.set(group_name, unquote(key), unquote(value))
    end
  end

  defmacro reporter(module, opts \\ []) do
    quote do
      :exometer_report.add_reporter(unquote(module), unquote(opts))
    end
  end
end
