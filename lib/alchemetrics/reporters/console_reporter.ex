defmodule Alchemetrics.ConsoleReporter do
  use Alchemetrics.CustomReporter

  def init(options) do
    IO.puts "Starting #{__MODULE__}: #{inspect options}"
    {:ok, options}
  end

  def report(group, measure, value, metadata, init_opts) do
    report = [group: group, measure: measure, value: value]
    |> Enum.concat(metadata)
    |> Enum.into(%{})
    IO.inspect report
  end
end

