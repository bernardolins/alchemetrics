defmodule Alchemetrics.Variable do
  @callback update(event :: Map.t, current :: any) :: any

  def current_value(var), do: Alchemetrics.Member.call(var, :current)
  def new_event(var, event), do: Alchemetrics.Member.cast(var, {:event, event})
  def reset(var), do: Alchemetrics.Member.cast(var, :reset)

  defmacro __using__(initial_value: initial_value) do
    quote do
      use Alchemetrics.Member
      @behaviour Alchemetrics.Variable

      def set_info(options) do
        {:ok, unquote(initial_value)}
      end

      def handle_join(_group, initial_value) do
        {:ok, initial_value}
      end

      def handle_message({:event, event}, current) do
        new_value = __MODULE__.update(event, current)
        {:noreply, new_value}
      end

      def handle_message(:reset, current) do
        {:noreply, unquote(initial_value)}
      end

      def handle_question(:current, _, current) do
        {:reply, current, current}
      end
    end
  end
end
