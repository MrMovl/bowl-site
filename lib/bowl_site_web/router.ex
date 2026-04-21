defmodule BowlSiteWeb.Router do
  use BowlSiteWeb, :router

  import BowlSiteWeb.UserAuth
  import Backpex.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {BowlSiteWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
    plug BowlSiteWeb.LocalePlug
  end

  pipeline :require_admin do
    plug :require_authenticated_user
  end

  # ----- Public routes -----
  scope "/", BowlSiteWeb do
    pipe_through :browser

    get "/", PageController, :home
    live "/shop", GalleryLive, :index
    live "/shop/:slug", ProductLive, :show
    post "/language", LanguageController, :set
    # Static pages catch-all — MUST be last
    live "/:slug", StaticPageLive, :show
  end

  # ----- Admin auth (no registration) -----
  scope "/admin", BowlSiteWeb do
    pipe_through :browser

    # Required by Backpex to set cookies for LiveResource views
    backpex_routes()

    get "/login", UserSessionController, :new
    post "/login", UserSessionController, :create
    delete "/logout", UserSessionController, :delete
  end

  # ----- Protected admin CMS -----
  scope "/admin", BowlSiteWeb do
    pipe_through [:browser, :require_admin]

    live_session :admin_cms,
      on_mount: [
        {BowlSiteWeb.UserAuth, :ensure_authenticated},
        Backpex.InitAssigns
      ] do
      live "/", Admin.DashboardLive, :index

      # Custom product form handles create/edit (multi-image upload).
      # These routes must come BEFORE live_resources so they take priority
      # over Backpex's generated /products/new and /products/:id/edit routes.
      live "/products/new", Admin.ProductFormLive, :new
      live "/products/:id/edit", Admin.ProductFormLive, :edit

      # Backpex LiveResources (list, show, search, delete)
      live_resources "/products", Admin.ProductResource
      live_resources "/pages", Admin.StaticPageResource
    end
  end
end
