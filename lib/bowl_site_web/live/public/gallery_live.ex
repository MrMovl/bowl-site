defmodule BowlSiteWeb.GalleryLive do
  use BowlSiteWeb, :live_view

  alias BowlSite.Catalog
  alias BowlSite.Locale

  @impl true
  def mount(_params, session, socket) do
    locale = session["locale"] || Locale.default_locale()

    {:ok,
     socket
     |> assign(:locale, locale)
     |> assign(:page_title, if(locale == "de", do: "Shop", else: "Shop"))
     |> assign(:materials, Catalog.list_materials())
     |> assign(:types, Catalog.list_types())
     |> assign(:filters, %{})}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    filters = parse_filters(params)
    products = Catalog.list_products(filters)

    {:noreply,
     socket
     |> assign(:filters, filters)
     |> assign(:products, products)}
  end

  @impl true
  def handle_event("filter_changed", params, socket) do
    new_filters =
      socket.assigns.filters
      |> Map.merge(params)
      |> reject_blank()

    {:noreply, push_patch(socket, to: ~p"/shop?#{new_filters}")}
  end

  @impl true
  def handle_event("clear_filters", _params, socket) do
    {:noreply, push_patch(socket, to: ~p"/shop")}
  end

  defp parse_filters(params) do
    params
    |> Map.take(["material", "type", "available", "price_min", "price_max"])
    |> reject_blank()
  end

  defp reject_blank(map) do
    Map.reject(map, fn {_k, v} -> v == "" or v == nil end)
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 py-10">
      <div class="flex flex-col md:flex-row gap-8">
        <!-- Filter sidebar -->
        <aside class="w-full md:w-56 shrink-0">
          <div class="bg-white rounded-lg border border-stone-200 p-5">
            <div class="flex items-center justify-between mb-4">
              <h2 class="text-sm font-semibold text-stone-700">
                <%= if @locale == "de", do: "Filtern", else: "Filter" %>
              </h2>
              <%= if @filters != %{} do %>
                <button
                  phx-click="clear_filters"
                  class="text-xs text-stone-400 hover:text-stone-700"
                >
                  <%= if @locale == "de", do: "Zurücksetzen", else: "Reset" %>
                </button>
              <% end %>
            </div>

            <form phx-change="filter_changed">
              <!-- Material filter -->
              <%= if @materials != [] do %>
                <div class="mb-5">
                  <label class="block text-xs font-medium text-stone-500 uppercase tracking-wide mb-2">
                    <%= if @locale == "de", do: "Material", else: "Material" %>
                  </label>
                  <select name="material" class="w-full text-sm border-stone-300 rounded focus:border-stone-400 focus:ring-0">
                    <option value="">
                      <%= if @locale == "de", do: "Alle", else: "All" %>
                    </option>
                    <%= for m <- @materials do %>
                      <option value={m} selected={@filters["material"] == m}><%= m %></option>
                    <% end %>
                  </select>
                </div>
              <% end %>

              <!-- Type filter -->
              <%= if @types != [] do %>
                <div class="mb-5">
                  <label class="block text-xs font-medium text-stone-500 uppercase tracking-wide mb-2">
                    <%= if @locale == "de", do: "Art", else: "Type" %>
                  </label>
                  <select name="type" class="w-full text-sm border-stone-300 rounded focus:border-stone-400 focus:ring-0">
                    <option value="">
                      <%= if @locale == "de", do: "Alle", else: "All" %>
                    </option>
                    <%= for t <- @types do %>
                      <option value={t} selected={@filters["type"] == t}><%= t %></option>
                    <% end %>
                  </select>
                </div>
              <% end %>

              <!-- Availability filter -->
              <div class="mb-5">
                <label class="flex items-center gap-2 text-sm text-stone-600 cursor-pointer">
                  <input
                    type="checkbox"
                    name="available"
                    value="true"
                    checked={@filters["available"] == "true"}
                    class="rounded border-stone-300 text-stone-700 focus:ring-0"
                  />
                  <%= if @locale == "de", do: "Nur verfügbar", else: "Available only" %>
                </label>
              </div>
            </form>
          </div>
        </aside>

        <!-- Product grid -->
        <div class="flex-1 min-w-0">
          <p class="text-sm text-stone-500 mb-6">
            <%= length(@products) %> <%= if @locale == "de", do: "Stücke", else: "pieces" %>
          </p>

          <%= if @products == [] do %>
            <div class="text-center py-20 text-stone-400">
              <p class="text-lg">
                <%= if @locale == "de", do: "Keine Stücke gefunden.", else: "No pieces found." %>
              </p>
            </div>
          <% else %>
            <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
              <%= for product <- @products do %>
                <.product_card product={product} locale={@locale} />
              <% end %>
            </div>
          <% end %>
        </div>
      </div>
    </div>
    """
  end
end
