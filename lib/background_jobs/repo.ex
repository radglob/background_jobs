defmodule BackgroundJobs.Repo do
  use Ecto.Repo,
    otp_app: :background_jobs,
    adapter: Ecto.Adapters.Postgres
end
