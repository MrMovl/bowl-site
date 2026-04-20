defmodule BowlSiteWeb.ProductCardComponent do
  use BowlSiteWeb, :html

  alias BowlSite.Catalog
  alias BowlSite.Locale

  attr :product, :map, required: true
  attr :locale, :string, default: "de"

  def product_card(assigns) do
    ~H"""
    <a href={~p"/shop/#{@product.slug}"} class="group block">
      <div class="relative aspect-square bg-stone-100 rounded overflow-hidden mb-3">
        <%= if cover = Catalog.cover_image(@product) do %>
          <img
            src={Catalog.image_url(cover, :thumb)}
            alt={cover.alt_text || Locale.t(@product, :name, @locale)}
            class="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300"
          />
        <% else %>
          <div class="w-full h-full flex items-center justify-center text-stone-300">
            <svg class="w-16 h-16" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1" d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z" />
            </svg>
          </div>
        <% end %>
        <%= unless @product.available do %>
          <div class="absolute inset-0 bg-stone-900/50 flex items-center justify-center">
            <span class="bg-white text-stone-800 text-xs font-medium px-3 py-1 rounded">
              <%= if @locale == "de", do: "Verkauft", else: "Sold" %>
            </span>
          </div>
        <% end %>
      </div>
      <div>
        <h3 class="text-sm font-medium text-stone-800 group-hover:text-stone-600">
          <%= Locale.t(@product, :name, @locale) %>
        </h3>
        <div class="flex items-center justify-between mt-1">
          <span class="text-xs text-stone-500 capitalize"><%= @product.material %></span>
          <span class="text-sm text-stone-700"><%= BowlSiteWeb.Helpers.format_price(@product.price_cents) %></span>
        </div>
      </div>
    </a>
    """
  end
end
