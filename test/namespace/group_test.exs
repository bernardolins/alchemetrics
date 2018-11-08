defmodule Alchemetrics.GroupTest do
  use ExUnit.Case

  alias Alchemetrics.Support.ValidationMember
  alias Alchemetrics.Support.TestConsumer

  describe "#create" do
    @tag capture_log: true
    test "stop the group creation if it is already registered" do
      Process.flag(:trap_exit, true)
      Alchemetrics.Group.create(:default)
      assert {:error, {:already_registered, _}} = Alchemetrics.Group.create(:default)
      assert_receive {:EXIT, _, {:already_registered, _}}
    end

    test "accepts atom group names" do
      assert {:ok, _} = Alchemetrics.Group.create(:default)
    end

    test "accepts string group names" do
      assert {:ok, _} = Alchemetrics.Group.create("group")
    end

    test "accepts list group names" do
      assert {:ok, _} = Alchemetrics.Group.create([:default, :for, :users])
    end

    test "accepts KeywordList group names" do
      assert {:ok, _} = Alchemetrics.Group.create(group_name: "my_group")
    end

    test "accepts integer group names" do
      assert {:ok, _} = Alchemetrics.Group.create(1)
    end
  end

  describe "#publish" do
    test "send message to a worker when it subscribe to the topic" do
      {:ok, pid} = Alchemetrics.Group.create(:default)
      TestConsumer.start_link(pid, self())
      Alchemetrics.Group.publish(:default, :message1)
      :timer.sleep(100)
      assert_received{:received, [:message1]}
    end

    test "does nothing when no consumers are started" do
      Alchemetrics.Group.create(:default)
      Alchemetrics.Group.publish(:default, :message1)
      :timer.sleep(100)
      refute_received{:received, [:message1]}
    end

    test "returns not_found if the group is not registered" do
      Process.flag(:trap_exit, true)
      assert {:error, :group_not_found} = Alchemetrics.Group.publish(:default, :some_message)
    end

    test "accepts publish messagens when the group name is an atom" do
      {:ok, pid} = Alchemetrics.Group.create(:default)
      TestConsumer.start_link(pid, self())
      Alchemetrics.Group.publish(:default, :message1)
      :timer.sleep(100)
      assert_received{:received, [:message1]}
    end

    test "accepts publish messagens when the group name is a string" do
      {:ok, pid} = Alchemetrics.Group.create("group")
      TestConsumer.start_link(pid, self())
      Alchemetrics.Group.publish("group", :message1)
      :timer.sleep(100)
      assert_received{:received, [:message1]}
    end

    test "accepts publish messagens when the group name is a list" do
      {:ok, pid} = Alchemetrics.Group.create([:default, :for, :users])
      TestConsumer.start_link(pid, self())
      Alchemetrics.Group.publish([:default, :for, :users], :message1)
      :timer.sleep(100)
      assert_received{:received, [:message1]}
    end

    test "accepts publish messagens when the group name is a KeywordList" do
      {:ok, pid} = Alchemetrics.Group.create(group_name: "my_group")
      TestConsumer.start_link(pid, self())
      Alchemetrics.Group.publish([group_name: "my_group"], :message1)
      :timer.sleep(100)
      assert_received{:received, [:message1]}
    end

    test "accepts publish messagens when the group name is a number" do
      {:ok, pid} = Alchemetrics.Group.create(1)
      TestConsumer.start_link(pid, self())
      Alchemetrics.Group.publish(1, :message1)
      :timer.sleep(100)
      assert_received{:received, [:message1]}
    end
  end

  describe "#join" do
    test "allows a client to join a group" do
      Alchemetrics.Group.create(:default)
      {:ok, pid} = ValidationMember.create(pid: self())
      assert :ok = Alchemetrics.Group.join(:default, pid)
      Alchemetrics.Group.publish(:default, :test_callback)
      assert_receive {:handle_message_called, _}
    end

    test "returns error when a client tries do join a group that does not exist" do
      {:ok, pid} = ValidationMember.create(pid: self())
      assert {:error, :not_found} == Alchemetrics.Group.join(:default, pid)
    end
  end
end
