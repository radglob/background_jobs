defmodule BackgroundJob do
  @type job_response :: :ok | {:err, String.t()}

  @doc """
  Definition of a task to perform.
  """
  @callback perform() :: job_response
  @callback perform(Keyword.t()) :: job_response

  defmacro __using__(_) do
    quote do
      @behaviour BackgroundJob

      @impl true
      def perform, do: {:error, "How dare you!"}

      @impl true
      def perform(opts \\ []), do: {:error, "How dare you!"}

      def perform_async(opts \\ []) do
        GenServer.call(BackgroundQueue, {:push, [__MODULE__, opts]})
      end

      def perform_in(delay, opts \\ []) do
        Process.send_after(BackgroundQueue, {:perform, __MODULE__, opts}, delay)
      end

      defoverridable perform: 0, perform: 1
    end
  end
end
