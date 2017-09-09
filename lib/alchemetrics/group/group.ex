defmodule Alchemetrics.Group do
  @enforce_keys [:name]
  defstruct [
    :name,
    metadata_keys: [],
    measures: [:sum, :total_sum],
    report_interval: 10_000
  ]
end
