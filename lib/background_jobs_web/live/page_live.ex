defmodule BackgroundJobsWeb.PageLive do
  use BackgroundJobsWeb, :live_view

  @topic "events"

  @impl true
  def mount(_params, _session, socket) do
    BackgroundJobsWeb.Endpoint.subscribe(@topic)
    Process.send_after(self(), :clear_events, 60_000)
    {:ok, assign(socket, events: [])}
  end

  @impl true
  def handle_info(:clear_events, socket) do
    Process.send_after(self(), :clear_events, 60_000)
    {:noreply, assign(socket, events: [])}
  end

  @impl true
  def handle_info(%{topic: @topic, payload: event}, socket) do
    {:noreply, assign(socket, events: [event] ++ socket.assigns.events)}
  end

  @impl true
  def handle_event("perform", _value, socket) do
    ExampleJob.perform()
    {:noreply, socket}
  end

  @impl true
  def handle_event("perform_async", _value, socket) do
    ExampleJob.perform_async()
    {:noreply, socket}
  end

  @impl true
  def handle_event("perform_in_5", _value, socket) do
    ExampleJob.perform_in(5000)
    {:noreply, socket}
  end

  defp topic, do: @topic
end
