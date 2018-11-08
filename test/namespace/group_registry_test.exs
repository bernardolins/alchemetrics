defmodule Alchemetrics.Registry.GroupTest do
  use ExUnit.Case
  alias Alchemetrics.Registry.Group

  setup do
    Registry.unregister_match(Alchemetrics.Registry.Group, :channel, [])
    Registry.unregister_match(Alchemetrics.Registry.Group, :channel1, [])
    Registry.unregister_match(Alchemetrics.Registry.Group, :channel2, [])
    Registry.unregister_match(Alchemetrics.Registry.Group, :channel3, [])
  end

  describe "#register" do
    test "register a new topic if no topic is registered for the same channel" do
      assert Registry.lookup(Alchemetrics.Registry.Group, :channel) == []
      assert :ok == Group.register(:channel)
      assert Registry.lookup(Alchemetrics.Registry.Group, :channel) == [{self(), []}]
    end

    test "register a new topic and channel options if no topic is registered for the same channel" do
      assert Registry.lookup(Alchemetrics.Registry.Group, :channel) == []
      assert :ok == Group.register(:channel, [some: "option"])
      assert Registry.lookup(Alchemetrics.Registry.Group, :channel) == [{self(), [some: "option"]}]
    end

    test "can't reg:channelister the same topic twice for a channel" do
      assert Registry.lookup(Alchemetrics.Registry.Group, :channel) == []
      assert :ok == Group.register(:channel)
      assert {:error, {:already_registered, self()}} == Group.register(:channel)
    end

    test "can reg:channelister several topics for a channel" do
      assert Registry.lookup(Alchemetrics.Registry.Group, :channel) == []
      assert :ok == Group.register(:channel1)
      assert :ok == Group.register(:channel2)
      assert :ok == Group.register(:channel3)
    end
  end

  describe "#lookup" do
    test "returns not_found when the topic does not exist" do
      assert {:error, :not_found} == Group.lookup(:channel)
    end

    test "returns ok and the pid of the topic when the topic is found" do
      assert :ok == Group.register(:channel)
      assert {:ok, {self(), []}} == Group.lookup(:channel)
    end
  end
end
