import Config

# Support DATABASE_URL for Docker; fall back to individual fields for local dev.
if url = System.get_env("DATABASE_URL") do
  config :bowl_site, BowlSite.Repo,
    url: url,
    stacktrace: true,
    show_sensitive_data_on_connection_error: true,
    pool_size: 10
else
  config :bowl_site, BowlSite.Repo,
    username: "postgres",
    password: "postgres",
    hostname: "localhost",
    database: "bowl_site_dev",
    stacktrace: true,
    show_sensitive_data_on_connection_error: true,
    pool_size: 10
end

config :bowl_site, BowlSiteWeb.Endpoint,
  # Bind to all interfaces so the container port is reachable from the host.
  http: [ip: {0, 0, 0, 0}, port: String.to_integer(System.get_env("PORT", "4000"))],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  secret_key_base: "dev_secret_key_base_at_least_64_chars_long_please_do_not_use_in_prod!!",
  watchers: [
    esbuild: {Esbuild, :install_and_run, [:bowl_site, ~w(--sourcemap=inline --watch)]},
    tailwind: {Tailwind, :install_and_run, [:bowl_site, ~w(--watch)]}
  ]

config :bowl_site, BowlSiteWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r"priv/static/(?!uploads/).*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"priv/gettext/.*(po)$",
      ~r"lib/bowl_site_web/(controllers|live|components)/.*(ex|heex)$"
    ]
  ]

config :bowl_site, dev_routes: true

config :logger, :console, format: "[$level] $message\n"

config :phoenix, :stacktrace_depth, 20

config :phoenix, :plug_init_mode, :runtime

config :phoenix_live_view,
  debug_heex_annotations: true,
  enable_expensive_runtime_checks: true
