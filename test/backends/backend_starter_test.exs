defmodule Alchemetrics.BackendStarterTest do
  use ExUnit.Case
  import Mock

  describe "#init" do
    test "starts all reporters on the :backends apllication variable with the configured options" do
      with_mock FakeBackend, [:passthrough], [init: fn(opts) -> {:ok, opts} end] do
        Alchemetrics.BackendStarter.init(:ok)
        assert called FakeBackend.start_link([some: "options"])
      end
    end
  end
end
