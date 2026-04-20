defmodule BowlSiteWeb.StaticPageLive do
  use BowlSiteWeb, :live_view

  alias BowlSite.Content
  alias BowlSite.Locale

  @impl true
  def mount(%{"slug" => slug}, session, socket) do
    locale = session["locale"] || Locale.default_locale()

    case Content.get_page_by_slug(slug) do
      {:ok, page} ->
        {:ok,
         socket
         |> assign(:locale, locale)
         |> assign(:page, page)
         |> assign(:page_title, Locale.t(page, :title, locale))}

      {:error, :not_found} ->
        {:ok,
         socket
         |> put_flash(:error, "Page not found")
         |> redirect(to: ~p"/")}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
      <h1 class="text-3xl font-light text-stone-800 mb-8">
        <%= Locale.t(@page, :title, @locale) %>
      </h1>
      <div class="prose prose-stone max-w-none text-stone-600 leading-relaxed">
        <%= raw(Locale.t(@page, :body, @locale)) %>
      </div>
    </div>
    """
  end
end
