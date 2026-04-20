import Config

config :bowl_site,
  ecto_repos: [BowlSite.Repo],
  generators: [timestamp_type: :utc_datetime]

config :bowl_site_web, BowlSiteWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: BowlSiteWeb.ErrorHTML, json: BowlSiteWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: BowlSite.PubSub,
  live_view: [signing_salt: "jq5eFk2R"]

config :bowl_site, BowlSiteWeb.Gettext, default_locale: "de", locales: ~w(de en)

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :json_library, Jason

config :waffle,
  storage: Waffle.Storage.Local,
  storage_dir_prefix: "priv/static",
  asset_host: {:system, "ASSET_HOST", "/"}

config :esbuild,
  version: "0.17.11",
  bowl_site: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{
      # Include both hex deps (for packages shipped as Hex) and node_modules
      # (for npm packages like alpinejs / daisyui used by Backpex).
      "NODE_PATH" =>
        Enum.join(
          [Path.expand("../deps", __DIR__), Path.expand("../assets/node_modules", __DIR__)],
          ":"
        )
    }
  ]

config :tailwind,
  version: "3.4.3",
  bowl_site: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

import_config "#{config_env()}.exs"
