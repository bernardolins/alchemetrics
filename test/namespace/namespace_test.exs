defmodule Alchemetrics.NamespaceTest do
  use ExUnit.Case

  test "stores the namespace configuration" do
    {:ok, _} = Alchemetrics.Namespace.start_link(:some_namespace)
    assert %Alchemetrics.Namespace{} = Alchemetrics.Namespace.info(:some_namespace)
  end
end
