defmodule BackgroundJobsWeb.PageLive do
  use BackgroundJobsWeb, :live_view

  @topic "events"

  @impl true
  def mount(_params, _session, socket) do
    BackgroundJobsWeb.Endpoint.subscribe(@topic)
    Process.send_after(self(), :clear_events, 60_000)
    {:ok, assign(socket, events: [], in_queue: 0)}
  end

  @impl true
  def handle_info(:clear_events, socket) do
    Process.send_after(self(), :clear_events, 60_000)
    {:noreply, assign(socket, events: [])}
  end

  @impl true
  def handle_info(%{topic: @topic, payload: event}, socket) do
    {:noreply,
     assign(socket,
       events: [event] ++ socket.assigns.events
     )}
  end

  @impl true
  def handle_info(%{topic: @topic, queued: 1}, socket) do
    {:noreply, assign(socket, in_queue: socket.assigns.in_queue + 1)}
  end

  @impl true
  def handle_info(%{topic: @topic, dequeued: 1}, socket) do
    {:noreply, assign(socket, in_queue: socket.assigns.in_queue - 1)}
  end

  @impl true
  def handle_event("perform", _value, socket) do
    ExampleJob.perform(queue_time: Time.utc_now(), event_type: "perform")
    {:noreply, socket}
  end

  @impl true
  def handle_event("perform_async", _value, socket) do
    ExampleJob.perform_async(queue_time: Time.utc_now(), event_type: "perform_async")
    {:noreply, socket}
  end

  @impl true
  def handle_event("perform_async_10", _value, socket) do
    queue_time = Time.utc_now()

    Enum.each(1..10, fn _ ->
      ExampleJob.perform_async(queue_time: queue_time, event_type: "perform_async")
    end)

    {:noreply, socket}
  end

  @impl true
  def handle_event("perform_in_5", _value, socket) do
    ExampleJob.perform_in(5000, queue_time: Time.utc_now(), event_type: "perform_in")
    {:noreply, socket}
  end

  defp topic, do: @topic
end
