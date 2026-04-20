defmodule BowlSiteWeb.PageController do
  use BowlSiteWeb, :controller

  alias BowlSite.Catalog

  def home(conn, _params) do
    featured = Catalog.list_featured_products(6)
    render(conn, :home, featured: featured)
  end
end
