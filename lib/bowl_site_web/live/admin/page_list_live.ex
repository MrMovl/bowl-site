defmodule BowlSiteWeb.Admin.PageListLive do
  use BowlSiteWeb, :live_view

  on_mount {BowlSiteWeb.UserAuth, :ensure_authenticated}

  alias BowlSite.Content

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Seiten")
     |> assign(:pages, Content.list_static_pages())}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <h1 class="text-xl font-semibold text-stone-800 mb-6">Statische Seiten</h1>

      <div class="bg-white rounded-lg border border-stone-200 overflow-hidden">
        <table class="w-full text-sm">
          <thead class="bg-stone-50 border-b border-stone-200">
            <tr>
              <th class="px-4 py-3 text-left text-xs font-medium text-stone-500 uppercase">Slug / URL</th>
              <th class="px-4 py-3 text-left text-xs font-medium text-stone-500 uppercase">Titel (DE)</th>
              <th class="px-4 py-3 text-left text-xs font-medium text-stone-500 uppercase">Status</th>
              <th class="px-4 py-3"></th>
            </tr>
          </thead>
          <tbody class="divide-y divide-stone-100">
            <%= for page <- @pages do %>
              <tr class="hover:bg-stone-50">
                <td class="px-4 py-3 font-mono text-stone-600">/<%= page.slug %></td>
                <td class="px-4 py-3 text-stone-800"><%= page.title_de %></td>
                <td class="px-4 py-3">
                  <span class={"text-xs px-2 py-1 rounded #{if page.published, do: "bg-emerald-100 text-emerald-700", else: "bg-stone-100 text-stone-500"}"}>
                    <%= if page.published, do: "Veröffentlicht", else: "Versteckt" %>
                  </span>
                </td>
                <td class="px-4 py-3 text-right">
                  <div class="flex justify-end gap-3">
                    <a href={~p"/#{page.slug}"} target="_blank" class="text-stone-400 hover:text-stone-700 text-xs">
                      Ansehen
                    </a>
                    <a href={~p"/admin/pages/#{page.id}/edit"} class="text-stone-600 hover:text-stone-900 text-xs font-medium">
                      Bearbeiten
                    </a>
                  </div>
                </td>
              </tr>
            <% end %>
          </tbody>
        </table>
      </div>
      <p class="text-xs text-stone-400 mt-3">
        Seiten können nicht gelöscht werden. Nutze "Status" um sie zu verbergen.
      </p>
    </div>
    """
  end
end
