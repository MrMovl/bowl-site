defmodule BowlSiteWeb.Admin.DashboardLive do
  use BowlSiteWeb, :live_view

  on_mount {BowlSiteWeb.UserAuth, :ensure_authenticated}

  alias BowlSite.Catalog
  alias BowlSite.Content

  @impl true
  def mount(_params, _session, socket) do
    products = Catalog.list_products()
    pages = Content.list_static_pages()

    {:ok,
     socket
     |> assign(:page_title, "Dashboard")
     |> assign(:product_count, length(products))
     |> assign(:available_count, Enum.count(products, & &1.available))
     |> assign(:page_count, length(pages))}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <h1 class="text-xl font-semibold text-stone-800 mb-6">Dashboard</h1>
      <div class="grid grid-cols-1 sm:grid-cols-3 gap-4">
        <div class="bg-white rounded-lg border border-stone-200 p-5">
          <p class="text-sm text-stone-500">Produkte gesamt</p>
          <p class="text-3xl font-light text-stone-800 mt-1"><%= @product_count %></p>
        </div>
        <div class="bg-white rounded-lg border border-stone-200 p-5">
          <p class="text-sm text-stone-500">Verfügbar</p>
          <p class="text-3xl font-light text-stone-800 mt-1"><%= @available_count %></p>
        </div>
        <div class="bg-white rounded-lg border border-stone-200 p-5">
          <p class="text-sm text-stone-500">Seiten</p>
          <p class="text-3xl font-light text-stone-800 mt-1"><%= @page_count %></p>
        </div>
      </div>
      <div class="mt-6 flex gap-4">
        <a href={~p"/admin/products/new"} class="bg-stone-800 text-white px-4 py-2 rounded text-sm hover:bg-stone-700">
          + Neues Produkt
        </a>
        <a href={~p"/admin/products"} class="border border-stone-200 text-stone-700 px-4 py-2 rounded text-sm hover:bg-stone-50">
          Produkte verwalten
        </a>
      </div>
    </div>
    """
  end
end
