defmodule Alchemetrics.Group.BufferTest do
  use ExUnit.Case
  alias Alchemetrics.Group.Buffer

  describe "#new" do
    test "creates a struct with an empty queue and demand 0" do
      assert %{buffer: {[], []}, demand: 0} = Buffer.new
   end

    test "accepts and option list and store it on structure" do
      assert %{options: [some: "option"]} = Buffer.new([some: "option"])
   end
  end

  describe "#buffer_message" do
    test "adds a new message on state if buffer is not full" do
      state = Buffer.new
      assert :queue.is_empty(state.buffer)
      assert state.buffer_size == 0
      state = Buffer.buffer_message(state, :message1)
      assert :queue.len(state.buffer) == 1
      assert state.buffer_size == 1
    end

    test "doest not store message on state if buffer is full" do
      state = Buffer.new([max_buffer_size: 1])
      assert :queue.is_empty(state.buffer)
      assert state.buffer_size == 0
      state = Buffer.buffer_message(state, :message1)
      assert :queue.len(state.buffer) == 1
      state = Buffer.buffer_message(state, :message1)
      assert :queue.len(state.buffer) == 1
      assert state.buffer_size == 1
    end
  end

  describe "#next_message" do
    test "returns empty and the state if there are no messages" do
      state = Buffer.new
      assert {:empty, _} = Buffer.next_message(state)
      assert state.buffer_size == 0
    end

    test "removes the oldest message from the state" do
      state =
        Buffer.new
        |> Buffer.buffer_message(:message1)
        |> Buffer.buffer_message(:message2)

      assert state.buffer_size == 2

      assert {:ok, :message1, state} = Buffer.next_message(state)
      assert state.buffer_size == 1
      assert {:ok, :message2, state} = Buffer.next_message(state)
      assert state.buffer_size == 0
    end
  end

  describe "#update_demand" do
    test "increments demand by delta when delta is provided" do
      state = Buffer.new
      assert state.demand == 0
      state = Buffer.update_demand(state, 8)
      assert state.demand == 8
    end

    test "increments demand by 1 when no delta is provided" do
      state = Buffer.new
      assert state.demand == 0
      state = Buffer.update_demand(state)
      assert state.demand == 1
    end

    test "accepts negative demand" do
      state = Buffer.new
      state = Buffer.update_demand(state, 10)
      assert state.demand == 10
      state = Buffer.update_demand(state, -1)
      assert state.demand == 9
    end

    test "does not decrement demand bellow 0" do
      state = Buffer.new
      assert state.demand == 0
      state = Buffer.update_demand(state, -1)
      assert state.demand == 0
    end
  end
end
