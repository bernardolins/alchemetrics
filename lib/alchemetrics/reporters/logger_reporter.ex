defmodule Alchemetrics.LoggerReporter do
  use Alchemetrics.CustomReporter
  require Logger

  def init([level: level] = options) do
    Logger.log(level, "Starting #{__MODULE__} with level #{level}")
    {:ok, options}
  end
  def init(_), do: init(level: :debug)

  def report(group, measure, value, metadata, init_opts) do
    report = [group: group, measure: measure, value: value]
    |> Enum.concat(metadata)
    |> Enum.into(%{})
    Logger.log(init_opts[:level], "#{inspect report}")
  end
end

