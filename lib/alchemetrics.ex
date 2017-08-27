defmodule Alchemetrics do
  alias Alchemetrics.Event
  alias Alchemetrics.Producer
  alias Alchemetrics.Exometer.Group

  @default_options %{
    metadata: %{},
    metrics: [:last_interval],
  }

  def report(metric_name, value, options \\ %{}) do
    Map.merge(@default_options, options)
    |> Map.put(:name, metric_name)
    |> Map.put(:value, value)
    |> Event.create
    |> Producer.enqueue
  end

  def collect(group_name, value, metadata \\ []) when is_atom(group_name) do
    Group.get_group(group_name) || raise "Group #{inspect group_name} does not exist"
    metadata = Keyword.take(metadata, Group.metadata_keys(group_name)) |> Enum.into(%{})
    measures = Group.measures(group_name)

    group_name = to_string(group_name)
    report(group_name, value, %{metadata: metadata, metrics: measures})
  end

  defmacro report_time(metric_name, options, function_body) do
    quote do
      {total_time, result} = :timer.tc(fn -> unquote(function_body) |> Keyword.get(:do) end)
      report(unquote(metric_name), total_time, unquote(options))
      result
    end
  end

  def count(metric_name, %{metadata: metadata}) do
    report(metric_name, 1, %{metrics: [:total, :last_interval], metadata: metadata})
  end
end
