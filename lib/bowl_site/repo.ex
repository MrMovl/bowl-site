defmodule BowlSite.Repo do
  use Ecto.Repo,
    otp_app: :bowl_site,
    adapter: Ecto.Adapters.Postgres
end
