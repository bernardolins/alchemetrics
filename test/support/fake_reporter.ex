# We need this because :exometer_reporter.add_reporter crashes if
# it is called with an invalid module that does not implements
# exometer_report behaviour
defmodule FakeBackend do
  use Alchemetrics.CustomBackend
  def init(opts), do: {:ok, opts}
  def report(_,_,_,_), do: {:ok, []}
end
