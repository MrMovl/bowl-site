defmodule BowlSite.Content.StaticPage do
  use Ecto.Schema
  import Ecto.Changeset

  schema "static_pages" do
    field :slug, :string
    field :title_de, :string
    field :title_en, :string
    field :body_de, :string
    field :body_en, :string
    field :meta_description_de, :string
    field :meta_description_en, :string
    field :published, :boolean, default: true

    timestamps(type: :utc_datetime)
  end

  def changeset(page, attrs) do
    page
    |> cast(attrs, [
      :slug, :title_de, :title_en, :body_de, :body_en,
      :meta_description_de, :meta_description_en, :published
    ])
    |> validate_required([:slug, :title_de, :title_en])
    |> unique_constraint(:slug)
  end
end
