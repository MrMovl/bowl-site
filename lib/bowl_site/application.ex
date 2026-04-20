defmodule BowlSite.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      BowlSiteWeb.Telemetry,
      BowlSite.Repo,
      {DNSCluster, query: Application.get_env(:bowl_site, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: BowlSite.PubSub},
      BowlSiteWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: BowlSite.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    BowlSiteWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
