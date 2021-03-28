defmodule BackgroundQueue do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: BackgroundQueue)
  end

  @impl true
  def init(_) do
    send(self(), :pop)
    {:ok, []}
  end

  @impl true
  def handle_call({:push, opts}, _from, jobs) do
    jobs = jobs ++ [opts]
    Phoenix.PubSub.broadcast(BackgroundJobs.PubSub, "events", %{topic: "events", queued: 1})
    {:reply, Enum.count(jobs), jobs}
  end

  @impl true
  def handle_call(:count, _from, jobs) do
    {:reply, Enum.count(jobs), jobs}
  end

  @impl true
  def handle_info(:pop, jobs) do
    case jobs do
      [] ->
        Process.send_after(self(), :pop, 100)
        {:noreply, jobs}

      [[task, opts] | rest] ->
        case task.perform(opts) do
          :ok ->
            Process.send_after(self(), :pop, 100)
            Phoenix.PubSub.broadcast(BackgroundJobs.PubSub, "events", %{topic: "events", dequeued: 1})
            {:noreply, rest}

          {:error, message} ->
            IO.puts(message)
            Process.send_after(self(), :pop, 100)
            {:noreply, jobs}
        end
    end
  end

  @impl true
  def handle_info({:perform, task, opts}, jobs) do
    task.perform(opts)
    {:noreply, jobs}
  end

  @impl true
  def handle_info(_, jobs) do
    IO.puts("Unexpected message, ignoring.")
    {:noreply, jobs}
  end
end
