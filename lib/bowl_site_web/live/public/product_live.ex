defmodule BowlSiteWeb.ProductLive do
  use BowlSiteWeb, :live_view

  alias BowlSite.Catalog
  alias BowlSite.Locale

  @impl true
  def mount(%{"slug" => slug}, session, socket) do
    locale = session["locale"] || Locale.default_locale()

    product = Catalog.get_product_by_slug!(slug)

    {:ok,
     socket
     |> assign(:locale, locale)
     |> assign(:product, product)
     |> assign(:selected_image_index, 0)
     |> assign(:page_title, Locale.t(product, :name, locale))}
  end

  @impl true
  def handle_event("select_image", %{"index" => index}, socket) do
    {:noreply, assign(socket, :selected_image_index, String.to_integer(index))}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 py-10">
      <!-- Breadcrumb -->
      <nav class="text-sm text-stone-500 mb-8">
        <a href={~p"/shop"} class="hover:text-stone-700">
          <%= if @locale == "de", do: "Shop", else: "Shop" %>
        </a>
        <span class="mx-2">›</span>
        <span class="text-stone-700"><%= Locale.t(@product, :name, @locale) %></span>
      </nav>

      <div class="grid grid-cols-1 md:grid-cols-2 gap-10 lg:gap-16">
        <!-- Image gallery -->
        <div>
          <!-- Main image -->
          <div class="aspect-square bg-stone-100 rounded-lg overflow-hidden mb-3">
            <%= if Enum.at(@product.product_images, @selected_image_index) do %>
              <% image = Enum.at(@product.product_images, @selected_image_index) %>
              <img
                src={Catalog.image_url(image, :large)}
                alt={image.alt_text || Locale.t(@product, :name, @locale)}
                class="w-full h-full object-cover"
              />
            <% else %>
              <div class="w-full h-full flex items-center justify-center text-stone-300">
                <svg class="w-24 h-24" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1" d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z" />
                </svg>
              </div>
            <% end %>
          </div>
          <!-- Thumbnails -->
          <%= if length(@product.product_images) > 1 do %>
            <div class="grid grid-cols-5 gap-2">
              <%= for {image, i} <- Enum.with_index(@product.product_images) do %>
                <button
                  phx-click="select_image"
                  phx-value-index={i}
                  class={"aspect-square rounded overflow-hidden border-2 #{if i == @selected_image_index, do: "border-stone-700", else: "border-transparent hover:border-stone-300"}"}
                >
                  <img
                    src={Catalog.image_url(image, :thumb)}
                    alt={image.alt_text || ""}
                    class="w-full h-full object-cover"
                  />
                </button>
              <% end %>
            </div>
          <% end %>
        </div>

        <!-- Product info -->
        <div class="flex flex-col">
          <div class="flex items-start justify-between gap-4 mb-4">
            <h1 class="text-2xl font-light text-stone-800">
              <%= Locale.t(@product, :name, @locale) %>
            </h1>
            <%= unless @product.available do %>
              <span class="shrink-0 bg-stone-200 text-stone-600 text-xs px-2 py-1 rounded mt-1">
                <%= if @locale == "de", do: "Verkauft", else: "Sold" %>
              </span>
            <% end %>
          </div>

          <p class="text-2xl text-stone-700 mb-6">
            <%= BowlSiteWeb.Helpers.format_price(@product.price_cents) %>
          </p>

          <!-- Dimensions -->
          <%= if @product.height_mm || @product.diameter_mm || @product.weight_g do %>
            <div class="bg-stone-50 rounded p-4 mb-6 grid grid-cols-3 gap-3 text-center">
              <%= if @product.height_mm do %>
                <div>
                  <p class="text-xs text-stone-400 mb-1">
                    <%= if @locale == "de", do: "Höhe", else: "Height" %>
                  </p>
                  <p class="text-sm font-medium text-stone-700"><%= @product.height_mm %> mm</p>
                </div>
              <% end %>
              <%= if @product.diameter_mm do %>
                <div>
                  <p class="text-xs text-stone-400 mb-1">
                    <%= if @locale == "de", do: "Durchmesser", else: "Diameter" %>
                  </p>
                  <p class="text-sm font-medium text-stone-700"><%= @product.diameter_mm %> mm</p>
                </div>
              <% end %>
              <%= if @product.weight_g do %>
                <div>
                  <p class="text-xs text-stone-400 mb-1">
                    <%= if @locale == "de", do: "Gewicht", else: "Weight" %>
                  </p>
                  <p class="text-sm font-medium text-stone-700"><%= @product.weight_g %> g</p>
                </div>
              <% end %>
            </div>
          <% end %>

          <!-- Material + Type -->
          <div class="flex gap-3 mb-6">
            <%= if @product.material do %>
              <span class="text-xs bg-stone-100 text-stone-600 px-3 py-1 rounded capitalize">
                <%= @product.material %>
              </span>
            <% end %>
            <%= if @product.type do %>
              <span class="text-xs bg-stone-100 text-stone-600 px-3 py-1 rounded capitalize">
                <%= @product.type %>
              </span>
            <% end %>
          </div>

          <!-- Description -->
          <%= if desc = Locale.t(@product, :description, @locale), desc != "" do %>
            <div class="text-stone-600 leading-relaxed mb-8 text-sm whitespace-pre-wrap">
              <%= desc %>
            </div>
          <% end %>

          <!-- Contact CTA -->
          <%= if @product.available do %>
            <a
              href={"mailto:kontakt@beispiel.de?subject=Anfrage: #{Locale.t(@product, :name, @locale)}"}
              class="mt-auto bg-stone-800 text-white text-center py-3 px-6 rounded hover:bg-stone-700 transition-colors text-sm font-medium"
            >
              <%= if @locale == "de", do: "Anfragen / Kaufen", else: "Contact to Buy" %>
            </a>
          <% else %>
            <button
              disabled
              class="mt-auto bg-stone-200 text-stone-400 text-center py-3 px-6 rounded text-sm font-medium cursor-not-allowed"
            >
              <%= if @locale == "de", do: "Verkauft", else: "Sold" %>
            </button>
          <% end %>
        </div>
      </div>
    </div>
    """
  end
end
