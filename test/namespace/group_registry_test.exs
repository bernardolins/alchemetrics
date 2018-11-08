defmodule Alchemetrics.Registry.GroupTest do
  use ExUnit.Case
  alias Alchemetrics.Registry.Group

  setup do
    Registry.unregister_match(Alchemetrics.Registry.Group, :group, [])
    Registry.unregister_match(Alchemetrics.Registry.Group, :group1, [])
    Registry.unregister_match(Alchemetrics.Registry.Group, :group2, [])
    Registry.unregister_match(Alchemetrics.Registry.Group, :group3, [])
  end

  describe "#register" do
    test "register a new topic if no topic is registered for the same group" do
      assert Registry.lookup(Alchemetrics.Registry.Group, :group) == []
      assert :ok == Group.register(:group)
      assert Registry.lookup(Alchemetrics.Registry.Group, :group) == [{self(), []}]
    end

    test "register a new topic and group options if no topic is registered for the same group" do
      assert Registry.lookup(Alchemetrics.Registry.Group, :group) == []
      assert :ok == Group.register(:group, [some: "option"])
      assert Registry.lookup(Alchemetrics.Registry.Group, :group) == [{self(), [some: "option"]}]
    end

    test "can't register the same topic twice for a group" do
      assert Registry.lookup(Alchemetrics.Registry.Group, :group) == []
      assert :ok == Group.register(:group)
      assert {:error, {:already_registered, self()}} == Group.register(:group)
    end

    test "can register several topics for a group" do
      assert Registry.lookup(Alchemetrics.Registry.Group, :group) == []
      assert :ok == Group.register(:group1)
      assert :ok == Group.register(:group2)
      assert :ok == Group.register(:group3)
    end
  end

  describe "#lookup" do
    test "returns not_found when the topic does not exist" do
      assert {:error, :not_found} == Group.lookup(:group)
    end

    test "returns ok and the pid of the topic when the topic is found" do
      assert :ok == Group.register(:group)
      assert {:ok, {self(), []}} == Group.lookup(:group)
    end
  end
end
