defmodule BowlSiteWeb.Admin.ProductResource do
  use Backpex.LiveResource,
    adapter_config: [
      schema: BowlSite.Catalog.Product,
      repo: BowlSite.Repo,
      update_changeset: &BowlSite.Catalog.Product.changeset/2,
      create_changeset: &BowlSite.Catalog.Product.changeset/2
    ],
    layout: {BowlSiteWeb.Layouts, :admin},
    pubsub: [
      server: BowlSite.PubSub,
      topic: "products",
      event_prefix: "product_"
    ]

  @impl Backpex.LiveResource
  def singular_name, do: "Produkt"

  @impl Backpex.LiveResource
  def plural_name, do: "Produkte"

  # Disable Backpex's own new/edit forms — image uploads require our custom form.
  # The "Bearbeiten" item action (below) links to the custom ProductFormLive instead.
  @impl Backpex.LiveResource
  def can?(_assigns, :new, _item), do: false
  def can?(_assigns, :edit, _item), do: false
  def can?(_assigns, _action, _item), do: true

  @impl Backpex.LiveResource
  def item_actions(default_actions) do
    default_actions ++
      [
        edit_custom: %{
          module: BowlSiteWeb.Admin.ProductResource.EditAction,
          label: "Bearbeiten"
        }
      ]
  end

  @impl Backpex.LiveResource
  def fields do
    [
      name_de: %{
        module: Backpex.Fields.Text,
        label: "Name (DE)",
        searchable: true
      },
      name_en: %{
        module: Backpex.Fields.Text,
        label: "Name (EN)",
        searchable: true
      },
      material: %{
        module: Backpex.Fields.Select,
        label: "Material",
        prompt: "— auswählen —",
        options: [
          {"Stoneware", "stoneware"},
          {"Earthenware", "earthenware"},
          {"Porcelain", "porcelain"},
          {"Holz", "wood"},
          {"Sonstiges", "other"}
        ]
      },
      type: %{
        module: Backpex.Fields.Select,
        label: "Art",
        prompt: "— auswählen —",
        options: [
          {"Schale", "bowl"},
          {"Becher", "mug"},
          {"Teller", "plate"},
          {"Vase", "vase"},
          {"Tasse", "cup"},
          {"Sonstiges", "other"}
        ]
      },
      price_cents: %{
        module: Backpex.Fields.Number,
        label: "Preis (Cent)"
      },
      available: %{
        module: Backpex.Fields.Boolean,
        label: "Verfügbar"
      },
      featured: %{
        module: Backpex.Fields.Boolean,
        label: "Auf Startseite"
      }
    ]
  end
end

defmodule BowlSiteWeb.Admin.ProductResource.EditAction do
  use Backpex.ItemAction

  import Phoenix.LiveView, only: [redirect: 2]
  use Phoenix.VerifiedRoutes,
    endpoint: BowlSiteWeb.Endpoint,
    router: BowlSiteWeb.Router,
    statics: BowlSiteWeb.static_paths()

  @impl Backpex.ItemAction
  def label, do: "Bearbeiten"

  @impl Backpex.ItemAction
  def handle(socket, [item | _], _params) do
    {:noreply, redirect(socket, to: ~p"/admin/products/#{item.id}/edit")}
  end
end
