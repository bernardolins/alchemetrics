defmodule Alchemetrics.Member do
  def call(who, message) do
    GenStage.call(who, message)
  end

  def cast(who, message) do
    GenStage.cast(who, message)
  end

  defmacro __using__(_) do
    quote do
      use GenStage
      require Logger

      def set_info(options), do: {:ok, options}
      def handle_join(_, info), do: {:ok, info}
      def handle_message(_, state), do: {:noreply, state}
      def handle_question(_, _, state), do: {:reply, :not_implemented, state}
      defoverridable [set_info: 1, handle_join: 2, handle_message: 2, handle_question: 3]

      def create(options \\ []) do
        GenStage.start_link(__MODULE__, options)
      end

      def init(options) do
        group_names = options
        |> Keyword.get(:join_groups, [])
        |> List.wrap

        case set_info(options) do
          {:ok, info} ->
            {:consumer, info, subscribe_to: group_names_to_pid(group_names)}
          {:stop, _} = stop ->
            stop
          invalid ->
            {:stop, :bad_return_value}
        end
      end

      def handle_call(message, from, state) do
        case proteced_handle_question(message, from, state) do
          {:reply, reply, new_state} ->
            {:reply, reply, [], new_state}
          {:stop, _} = stop ->
            stop
          invalid_return ->
            {:stop, {:shutdown, :bad_return_value}, state}
        end
      end

      def handle_cast(message, state) do
        case proteced_handle_message(message, state) do
          {:noreply, state} ->
            {:noreply, [], state}
          {:stop, _} = stop ->
            stop
          _ ->
            {:stop, {:shutdown, :bad_return_value}, state}
        end
      end

      def handle_info(message, state) do
        case proteced_handle_message(message, state) do
          {:noreply, state} ->
            {:noreply, [], state}
          {:stop, _} = stop ->
            stop
          invalid_return ->
            {:stop, {:bad_return_value, invalid_return}}
        end
      end

      def handle_subscribe(:producer, opts, _, info) do
        group_name = opts[:group_name]
        case handle_join(group_name, info) do
          {:ok, info} ->
            {:automatic, info}
          {:stop, _} = stop ->
            stop
          invalid_return ->
            {:stop, {:shutdown, :bad_return_value}, info}
        end
      end

      def handle_events(messages, _, state) do
        handle_messages(messages, state)
      end

      defp group_names_to_pid([]), do: []
      defp group_names_to_pid(group_names) do
        Enum.reduce(group_names, [], fn(group_name, list) ->
          case Alchemetrics.Registry.Group.lookup(group_name) do
            {:ok, {pid, _}} ->
              [{pid, group_name: group_name}|list]
            {:error, :not_found} ->
              Logger.warn("Group not found: #{inspect group_name}")
              list
          end
        end)
      end

      defp handle_messages([], state), do: {:noreply, [], state}
      defp handle_messages([message|messages], state) do
        case proteced_handle_message(message, state) do
          {:noreply, new_state} ->
            handle_messages(messages, new_state)
          _ ->
            {:stop, :normal, nil}
        end
      end

      defp proteced_handle_message(message, state) do
        try do
          handle_message(message, state)
        rescue
          FunctionClauseError ->
            {:noreply, state}
          CaseClauseError ->
            {:noreply, state}
        end
      end

      defp proteced_handle_question(message, from, state) do
        try do
          handle_question(message, from, state)
        rescue
          FunctionClauseError ->
            {:reply, :not_implemented, state}
          CaseClauseError ->
            {:reply, :not_implemented, state}
        end
      end
    end
  end
end
