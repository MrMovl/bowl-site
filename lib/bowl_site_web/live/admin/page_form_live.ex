defmodule BowlSiteWeb.Admin.PageFormLive do
  use BowlSiteWeb, :live_view

  on_mount {BowlSiteWeb.UserAuth, :ensure_authenticated}

  alias BowlSite.Content

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    page = Content.get_static_page!(String.to_integer(id))
    changeset = Content.change_static_page(page)

    {:ok,
     socket
     |> assign(:page_title, "Seite bearbeiten")
     |> assign(:page, page)
     |> assign(:form, to_form(changeset))}
  end

  @impl true
  def handle_event("validate", %{"static_page" => params}, socket) do
    changeset =
      socket.assigns.page
      |> Content.change_static_page(params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :form, to_form(changeset))}
  end

  @impl true
  def handle_event("save", %{"static_page" => params}, socket) do
    case Content.update_static_page(socket.assigns.page, params) do
      {:ok, _page} ->
        {:noreply,
         socket
         |> put_flash(:info, "Seite gespeichert.")
         |> redirect(to: ~p"/admin/pages")}

      {:error, changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-3xl">
      <div class="flex items-center gap-4 mb-6">
        <a href={~p"/admin/pages"} class="text-stone-400 hover:text-stone-700 text-sm">← Zurück</a>
        <h1 class="text-xl font-semibold text-stone-800">
          Seite bearbeiten: <span class="font-mono text-stone-500">/<%= @page.slug %></span>
        </h1>
      </div>

      <.form for={@form} phx-change="validate" phx-submit="save" class="space-y-6">
        <div class="bg-white rounded-lg border border-stone-200 p-6 space-y-4">
          <h2 class="text-sm font-semibold text-stone-600 uppercase tracking-wide">Titel</h2>
          <div class="grid grid-cols-2 gap-4">
            <.input field={@form[:title_de]} label="Titel (Deutsch)" required />
            <.input field={@form[:title_en]} label="Title (English)" required />
          </div>
        </div>

        <div class="bg-white rounded-lg border border-stone-200 p-6 space-y-4">
          <h2 class="text-sm font-semibold text-stone-600 uppercase tracking-wide">Inhalt</h2>
          <p class="text-xs text-stone-400">HTML-Tags werden unterstützt (z.B. &lt;p&gt;, &lt;h2&gt;, &lt;ul&gt;, &lt;strong&gt;).</p>
          <.input field={@form[:body_de]} type="textarea" label="Inhalt (Deutsch)" rows="12" />
          <.input field={@form[:body_en]} type="textarea" label="Content (English)" rows="12" />
        </div>

        <div class="bg-white rounded-lg border border-stone-200 p-6 space-y-4">
          <h2 class="text-sm font-semibold text-stone-600 uppercase tracking-wide">SEO (optional)</h2>
          <div class="grid grid-cols-2 gap-4">
            <.input field={@form[:meta_description_de]} label="Meta Description (DE)" />
            <.input field={@form[:meta_description_en]} label="Meta Description (EN)" />
          </div>
        </div>

        <div class="bg-white rounded-lg border border-stone-200 p-6">
          <.input field={@form[:published]} type="checkbox" label="Veröffentlicht" />
        </div>

        <div class="flex gap-3">
          <.button type="submit">Speichern</.button>
          <a href={~p"/admin/pages"} class="px-4 py-2 text-sm text-stone-600 hover:text-stone-900">
            Abbrechen
          </a>
          <a href={~p"/#{@page.slug}"} target="_blank" class="px-4 py-2 text-sm text-stone-400 hover:text-stone-600 ml-auto">
            Vorschau →
          </a>
        </div>
      </.form>
    </div>
    """
  end
end
