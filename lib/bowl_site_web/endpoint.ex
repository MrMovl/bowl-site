defmodule BowlSiteWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :bowl_site

  @session_options [
    store: :cookie,
    key: "_bowl_site_key",
    signing_salt: "5Z2vXl3m",
    same_site: "Lax"
  ]

  socket "/live", Phoenix.LiveView.Socket,
    websocket: [connect_info: [session: @session_options]],
    longpoll: [connect_info: [session: @session_options]]

  plug Plug.Static,
    at: "/",
    from: :bowl_site,
    gzip: false,
    only: BowlSiteWeb.static_paths()

  plug Plug.Static,
    at: "/uploads",
    from: {:bowl_site, "priv/static/uploads"},
    gzip: false

  if code_reloading? do
    socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket
    plug Phoenix.LiveReloader
    plug Phoenix.CodeReloader
    plug Phoenix.Ecto.CheckRepoStatus, otp_app: :bowl_site
  end

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head
  plug Plug.Session, @session_options
  plug BowlSiteWeb.Router
end
