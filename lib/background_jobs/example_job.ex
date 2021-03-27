defmodule ExampleJob do
  use BackgroundJob

  def perform(_opts \\ []) do
    start_time = Time.utc_now()
    sleep_time = round(:random.uniform() * 1000)
    Process.sleep(sleep_time)

    Phoenix.PubSub.broadcast(
      BackgroundJobs.PubSub,
      "events",
      %{
        topic: "events",
        payload: %{
          start_time: start_time,
          time_elapsed: sleep_time
        }
      }
    )

    :ok
  end
end
