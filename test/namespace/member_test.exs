defmodule Alchemetrics.MemberTest do
  use ExUnit.Case
  alias Alchemetrics.Support.ValidationMember

  describe "callback set_info" do
    @tag capture_log: true
    test "aborts creation when the return value is not {:ok, _}" do
      Process.flag(:trap_exit, true)
      assert {:error, :bad_return_value} = ValidationMember.create(invalid_return: true)
      assert_receive {:EXIT, _, :bad_return_value}
    end

    test "is called when a client is created with the argument passed to create" do
      assert {:ok, pid} = ValidationMember.create(pid: self())
      assert_receive {:set_info_called, ^pid}
    end
  end

  describe "callback handle_join" do
    test "is called when a client joins a group" do
      Alchemetrics.Group.create(:test_callback)
      {:ok, pid} = ValidationMember.create(pid: self())
      Alchemetrics.Group.join(:test_callback, pid)
      assert_receive {:handle_join_called, :test_callback, ^pid}
    end

    test "is called when a client joins a group on it's creation" do
      Alchemetrics.Group.create(:test_callback)
      {:ok, pid} = ValidationMember.create(pid: self(), join_groups: [:test_callback])
      assert_receive {:handle_join_called, :test_callback, ^pid}
    end

    @tag capture_log: true
    test "exits process when the return value is not {:ok, _}" do
      Process.flag(:trap_exit, true)
      Alchemetrics.Group.create(:invalid_return)
      {:ok, pid} = ValidationMember.create()
      catch_exit Alchemetrics.Group.join(:invalid_return, pid)
      assert_receive {:EXIT, ^pid, {:shutdown, :bad_return_value}}
    end
  end

  describe "callback handle_message" do
    test "is called when a client receive a private message" do
      {:ok, pid} = ValidationMember.create(pid: self())
      Alchemetrics.Member.cast(pid, :test_callback)
      assert_receive {:handle_message_called, ^pid}
    end

    test "is called when a client receive a message from the group" do
      Alchemetrics.Group.create(:group)
      {:ok, pid} = ValidationMember.create(pid: self())
      Alchemetrics.Group.join(:group, pid)
      Alchemetrics.Group.publish(:group, :test_callback)
      assert_receive {:handle_message_called, ^pid}
    end

    test "is called when a client receive a send_after message" do
      {:ok, pid} = ValidationMember.create(pid: self())
      :timer.send_after(10, pid, :test_callback)
      assert_receive {:handle_message_called, ^pid}
    end

    @tag capture_log: true
    test "exits process when the return value is not {:noreply, _}" do
      Process.flag(:trap_exit, true)
      {:ok, pid} = ValidationMember.create()
      Alchemetrics.Member.cast(pid, :invalid_return)
      assert_receive {:EXIT, ^pid, {:shutdown, :bad_return_value}}
    end
  end

  describe "callback handle_question" do
    test "is called when a client receive a private message" do
      {:ok, pid} = ValidationMember.create(pid: self())
      assert :handle_question_called == Alchemetrics.Member.call(pid, :test_callback)
    end

    test "returns :not_implemented when a client receives an unkwnown message" do
      {:ok, pid} = ValidationMember.create(pid: self())
      assert :not_implemented == Alchemetrics.Member.call(pid, :unknown_message)
    end

    @tag capture_log: true
    test "exits process when the return value is not {:reply, _, _}" do
      Process.flag(:trap_exit, true)
      {:ok, pid} = ValidationMember.create(pid: self())
      catch_exit Alchemetrics.Member.call(pid, :invalid_return)
      assert_receive {:EXIT, ^pid, {:shutdown, :bad_return_value}}
    end
  end
end
