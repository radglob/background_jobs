defmodule ExampleJob do
  use BackgroundJob

  def perform(queue_time: queue_time, event_type: event_type) do
    start_time = Time.utc_now()

    Phoenix.PubSub.broadcast(
      BackgroundJobs.PubSub,
      "events",
      %{
        topic: "events",
        payload: %{
          queue_time: queue_time,
          start_time: start_time,
          event_type: event_type
        }
      }
    )

    :ok
  end
end
