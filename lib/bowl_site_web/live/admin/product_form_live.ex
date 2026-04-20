defmodule BowlSiteWeb.Admin.ProductFormLive do
  use BowlSiteWeb, :live_view

  on_mount {BowlSiteWeb.UserAuth, :ensure_authenticated}

  alias BowlSite.Catalog
  alias BowlSite.Catalog.Product

  @impl true
  def mount(params, _session, socket) do
    socket =
      socket
      |> allow_upload(:images,
        accept: ~w(.jpg .jpeg .png .webp),
        max_entries: 10,
        max_file_size: 10_000_000
      )

    case params do
      %{"id" => id} ->
        product = Catalog.get_product!(String.to_integer(id))
        changeset = Catalog.change_product(product)

        {:ok,
         socket
         |> assign(:page_title, "Produkt bearbeiten")
         |> assign(:product, product)
         |> assign(:form, to_form(changeset))
         |> assign(:action, :edit)}

      _ ->
        changeset = Catalog.change_product(%Product{})

        {:ok,
         socket
         |> assign(:page_title, "Neues Produkt")
         |> assign(:product, %Product{product_images: []})
         |> assign(:form, to_form(changeset))
         |> assign(:action, :new)}
    end
  end

  @impl true
  def handle_event("validate", %{"product" => params}, socket) do
    changeset =
      socket.assigns.product
      |> Catalog.change_product(params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :form, to_form(changeset))}
  end

  @impl true
  def handle_event("save", %{"product" => params}, socket) do
    case socket.assigns.action do
      :new -> save_new(socket, params)
      :edit -> save_edit(socket, params)
    end
  end

  @impl true
  def handle_event("cancel_upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :images, ref)}
  end

  @impl true
  def handle_event("delete_image", %{"id" => id}, socket) do
    image =
      socket.assigns.product.product_images
      |> Enum.find(&(&1.id == String.to_integer(id)))

    if image do
      Catalog.delete_product_image(image)
      product = Catalog.get_product!(socket.assigns.product.id)
      {:noreply, assign(socket, :product, product)}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_event("reorder_images", %{"ids" => ids}, socket) do
    ordered_ids = Enum.map(ids, &String.to_integer/1)
    Catalog.reorder_images(socket.assigns.product, ordered_ids)
    product = Catalog.get_product!(socket.assigns.product.id)
    {:noreply, assign(socket, :product, product)}
  end

  defp save_new(socket, params) do
    case Catalog.create_product(params) do
      {:ok, product} ->
        upload_images(socket, product)

        {:noreply,
         socket
         |> put_flash(:info, "Produkt erstellt.")
         |> redirect(to: ~p"/admin/products")}

      {:error, changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end

  defp save_edit(socket, params) do
    case Catalog.update_product(socket.assigns.product, params) do
      {:ok, product} ->
        upload_images(socket, product)

        {:noreply,
         socket
         |> put_flash(:info, "Produkt gespeichert.")
         |> redirect(to: ~p"/admin/products")}

      {:error, changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end

  defp upload_images(socket, product) do
    consume_uploaded_entries(socket, :images, fn %{path: path}, entry ->
      upload_params = %{path: path, file_name: entry.client_name}
      Catalog.add_product_image(product, upload_params, %{"alt_text" => entry.client_name})
      {:ok, :uploaded}
    end)
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-2xl">
      <div class="flex items-center gap-4 mb-6">
        <a href={~p"/admin/products"} class="text-stone-400 hover:text-stone-700 text-sm">← Zurück</a>
        <h1 class="text-xl font-semibold text-stone-800"><%= @page_title %></h1>
      </div>

      <.form for={@form} phx-change="validate" phx-submit="save" class="space-y-6">
        <div class="bg-white rounded-lg border border-stone-200 p-6 space-y-4">
          <h2 class="text-sm font-semibold text-stone-600 uppercase tracking-wide">Grunddaten</h2>

          <div class="grid grid-cols-2 gap-4">
            <.input field={@form[:name_de]} label="Name (Deutsch)" required />
            <.input field={@form[:name_en]} label="Name (Englisch)" required />
          </div>

          <.input field={@form[:slug]} label="Slug (URL)" placeholder="Wird automatisch gesetzt" />

          <div class="grid grid-cols-2 gap-4">
            <.input
              field={@form[:material]}
              type="select"
              label="Material"
              prompt="— auswählen —"
              options={Enum.map(Product.valid_materials(), &{String.capitalize(&1), &1})}
            />
            <.input
              field={@form[:type]}
              type="select"
              label="Art"
              prompt="— auswählen —"
              options={Enum.map(Product.valid_types(), &{String.capitalize(&1), &1})}
            />
          </div>

          <.input field={@form[:price_cents]} type="number" label="Preis (in Cent, z.B. 4500 = €45,00)" required />

          <div class="grid grid-cols-3 gap-4">
            <.input field={@form[:height_mm]} type="number" label="Höhe (mm)" />
            <.input field={@form[:diameter_mm]} type="number" label="Durchmesser (mm)" />
            <.input field={@form[:weight_g]} type="number" label="Gewicht (g)" />
          </div>
        </div>

        <div class="bg-white rounded-lg border border-stone-200 p-6 space-y-4">
          <h2 class="text-sm font-semibold text-stone-600 uppercase tracking-wide">Beschreibung</h2>
          <.input field={@form[:description_de]} type="textarea" label="Beschreibung (Deutsch)" rows="5" />
          <.input field={@form[:description_en]} type="textarea" label="Description (English)" rows="5" />
        </div>

        <div class="bg-white rounded-lg border border-stone-200 p-6 space-y-4">
          <h2 class="text-sm font-semibold text-stone-600 uppercase tracking-wide">Sichtbarkeit</h2>
          <div class="flex gap-6">
            <.input field={@form[:available]} type="checkbox" label="Verfügbar" />
            <.input field={@form[:featured]} type="checkbox" label="Auf Startseite zeigen" />
          </div>
          <.input field={@form[:sort_order]} type="number" label="Sortierreihenfolge" />
        </div>

        <!-- Image management (existing images) -->
        <%= if @action == :edit and @product.product_images != [] do %>
          <div class="bg-white rounded-lg border border-stone-200 p-6">
            <h2 class="text-sm font-semibold text-stone-600 uppercase tracking-wide mb-4">
              Bilder (<%= length(@product.product_images) %>)
            </h2>
            <div class="grid grid-cols-4 gap-3">
              <%= for image <- @product.product_images do %>
                <div class="relative group">
                  <img
                    src={Catalog.image_url(image, :thumb)}
                    alt={image.alt_text || ""}
                    class="w-full aspect-square object-cover rounded border border-stone-200"
                  />
                  <button
                    type="button"
                    phx-click="delete_image"
                    phx-value-id={image.id}
                    data-confirm="Bild löschen?"
                    class="absolute top-1 right-1 bg-rose-500 text-white rounded-full w-5 h-5 text-xs flex items-center justify-center opacity-0 group-hover:opacity-100 transition-opacity"
                  >×</button>
                  <%= if image.position == 0 do %>
                    <span class="absolute bottom-1 left-1 bg-stone-800 text-white text-xs px-1 rounded">Cover</span>
                  <% end %>
                </div>
              <% end %>
            </div>
          </div>
        <% end %>

        <!-- Upload new images -->
        <div class="bg-white rounded-lg border border-stone-200 p-6">
          <h2 class="text-sm font-semibold text-stone-600 uppercase tracking-wide mb-4">
            Bilder hochladen
          </h2>
          <div
            phx-drop-target={@uploads.images.ref}
            class="border-2 border-dashed border-stone-300 rounded-lg p-6 text-center hover:border-stone-400 transition-colors"
          >
            <.live_file_input upload={@uploads.images} class="hidden" />
            <label for={@uploads.images.ref} class="cursor-pointer">
              <p class="text-sm text-stone-500">
                Bilder hierher ziehen oder <span class="text-stone-700 font-medium underline">auswählen</span>
              </p>
              <p class="text-xs text-stone-400 mt-1">JPG, PNG, WebP · max. 10 MB pro Bild</p>
            </label>
          </div>

          <%= for entry <- @uploads.images.entries do %>
            <div class="flex items-center gap-3 mt-3">
              <.live_img_preview entry={entry} class="w-12 h-12 object-cover rounded" />
              <div class="flex-1 text-sm text-stone-600 truncate"><%= entry.client_name %></div>
              <div class="text-xs text-stone-400"><%= trunc(entry.progress) %>%</div>
              <button type="button" phx-click="cancel_upload" phx-value-ref={entry.ref} class="text-rose-400 hover:text-rose-700 text-xs">×</button>
            </div>
            <%= for err <- upload_errors(@uploads.images, entry) do %>
              <p class="text-xs text-rose-600 mt-1"><%= error_to_string(err) %></p>
            <% end %>
          <% end %>
        </div>

        <div class="flex gap-3">
          <.button type="submit">
            <%= if @action == :new, do: "Erstellen", else: "Speichern" %>
          </.button>
          <a href={~p"/admin/products"} class="px-4 py-2 text-sm text-stone-600 hover:text-stone-900">
            Abbrechen
          </a>
        </div>
      </.form>
    </div>
    """
  end

  defp error_to_string(:too_large), do: "Datei zu groß (max. 10 MB)"
  defp error_to_string(:not_accepted), do: "Ungültiges Format (nur JPG, PNG, WebP)"
  defp error_to_string(:too_many_files), do: "Zu viele Dateien"
  defp error_to_string(err), do: inspect(err)
end
