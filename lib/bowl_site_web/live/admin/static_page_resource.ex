defmodule BowlSiteWeb.Admin.StaticPageResource do
  use Backpex.LiveResource,
    adapter_config: [
      schema: BowlSite.Content.StaticPage,
      repo: BowlSite.Repo,
      update_changeset: &BowlSite.Content.StaticPage.changeset/2,
      create_changeset: &BowlSite.Content.StaticPage.changeset/2
    ],
    layout: {BowlSiteWeb.Layouts, :admin}

  @impl Backpex.LiveResource
  def singular_name, do: "Seite"

  @impl Backpex.LiveResource
  def plural_name, do: "Seiten"

  # Static pages should not be deleteable — use published: false to hide them.
  @impl Backpex.LiveResource
  def can?(_assigns, :delete, _item), do: false
  def can?(_assigns, _action, _item), do: true

  @impl Backpex.LiveResource
  def fields do
    [
      slug: %{
        module: Backpex.Fields.Text,
        label: "Slug (URL-Pfad)"
      },
      title_de: %{
        module: Backpex.Fields.Text,
        label: "Titel (Deutsch)",
        searchable: true
      },
      title_en: %{
        module: Backpex.Fields.Text,
        label: "Title (English)"
      },
      body_de: %{
        module: Backpex.Fields.Textarea,
        label: "Inhalt (Deutsch)"
      },
      body_en: %{
        module: Backpex.Fields.Textarea,
        label: "Content (English)"
      },
      meta_description_de: %{
        module: Backpex.Fields.Text,
        label: "Meta Description (DE)",
        only: [:new, :edit, :show]
      },
      meta_description_en: %{
        module: Backpex.Fields.Text,
        label: "Meta Description (EN)",
        only: [:new, :edit, :show]
      },
      published: %{
        module: Backpex.Fields.Boolean,
        label: "Veröffentlicht"
      }
    ]
  end
end
