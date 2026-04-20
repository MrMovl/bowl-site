defmodule BowlSiteWeb.Admin.ProductListLive do
  use BowlSiteWeb, :live_view

  on_mount {BowlSiteWeb.UserAuth, :ensure_authenticated}

  alias BowlSite.Catalog

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Produkte")
     |> assign(:products, Catalog.list_products())}
  end

  @impl true
  def handle_event("toggle_available", %{"id" => id}, socket) do
    product = Catalog.get_product!(String.to_integer(id))
    {:ok, _} = Catalog.toggle_availability(product)
    {:noreply, assign(socket, :products, Catalog.list_products())}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    product = Catalog.get_product!(String.to_integer(id))
    {:ok, _} = Catalog.delete_product(product)
    {:noreply, assign(socket, :products, Catalog.list_products())}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <div class="flex items-center justify-between mb-6">
        <h1 class="text-xl font-semibold text-stone-800">Produkte</h1>
        <a
          href={~p"/admin/products/new"}
          class="bg-stone-800 text-white px-4 py-2 rounded text-sm hover:bg-stone-700"
        >
          + Neues Produkt
        </a>
      </div>

      <div class="bg-white rounded-lg border border-stone-200 overflow-hidden">
        <table class="w-full text-sm">
          <thead class="bg-stone-50 border-b border-stone-200">
            <tr>
              <th class="px-4 py-3 text-left text-xs font-medium text-stone-500 uppercase">Name</th>
              <th class="px-4 py-3 text-left text-xs font-medium text-stone-500 uppercase">Material</th>
              <th class="px-4 py-3 text-left text-xs font-medium text-stone-500 uppercase">Preis</th>
              <th class="px-4 py-3 text-left text-xs font-medium text-stone-500 uppercase">Status</th>
              <th class="px-4 py-3"></th>
            </tr>
          </thead>
          <tbody class="divide-y divide-stone-100">
            <%= for product <- @products do %>
              <tr class="hover:bg-stone-50">
                <td class="px-4 py-3">
                  <div class="font-medium text-stone-800"><%= product.name_de %></div>
                  <div class="text-xs text-stone-400"><%= product.slug %></div>
                </td>
                <td class="px-4 py-3 text-stone-600 capitalize"><%= product.material %></td>
                <td class="px-4 py-3 text-stone-600">
                  <%= BowlSiteWeb.Helpers.format_price(product.price_cents) %>
                </td>
                <td class="px-4 py-3">
                  <button
                    phx-click="toggle_available"
                    phx-value-id={product.id}
                    class={"text-xs px-2 py-1 rounded font-medium #{if product.available, do: "bg-emerald-100 text-emerald-700 hover:bg-emerald-200", else: "bg-stone-100 text-stone-500 hover:bg-stone-200"}"}
                  >
                    <%= if product.available, do: "Verfügbar", else: "Verkauft" %>
                  </button>
                </td>
                <td class="px-4 py-3 text-right">
                  <div class="flex justify-end gap-3">
                    <a href={~p"/shop/#{product.slug}"} target="_blank" class="text-stone-400 hover:text-stone-700 text-xs">
                      Ansehen
                    </a>
                    <a href={~p"/admin/products/#{product.id}/edit"} class="text-stone-600 hover:text-stone-900 text-xs font-medium">
                      Bearbeiten
                    </a>
                    <button
                      phx-click="delete"
                      phx-value-id={product.id}
                      data-confirm="Dieses Produkt wirklich löschen?"
                      class="text-rose-400 hover:text-rose-700 text-xs"
                    >
                      Löschen
                    </button>
                  </div>
                </td>
              </tr>
            <% end %>
          </tbody>
        </table>
        <%= if @products == [] do %>
          <div class="text-center py-12 text-stone-400">
            Noch keine Produkte vorhanden.
          </div>
        <% end %>
      </div>
    </div>
    """
  end
end
