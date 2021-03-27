defmodule ExampleJob do
  use BackgroundJob

  def perform(_opts \\ []) do
    :ok
  end
end
