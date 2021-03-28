defmodule BackgroundJobs.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      BackgroundJobsWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: BackgroundJobs.PubSub},
      # Start the Endpoint (http/https)
      BackgroundJobsWeb.Endpoint,
      # Start a worker by calling: BackgroundJobs.Worker.start_link(arg)
      # {BackgroundJobs.Worker, arg}
      {BackgroundQueue, []}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: BackgroundJobs.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    BackgroundJobsWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
