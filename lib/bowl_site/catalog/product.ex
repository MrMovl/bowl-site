defmodule BowlSite.Catalog.Product do
  use Ecto.Schema
  import Ecto.Changeset

  @valid_materials ~w(stoneware earthenware porcelain wood other)
  @valid_types ~w(bowl mug plate vase cup other)

  def valid_materials, do: @valid_materials
  def valid_types, do: @valid_types

  schema "products" do
    field :name_de, :string
    field :name_en, :string
    field :slug, :string
    field :description_de, :string
    field :description_en, :string
    field :material, :string
    field :type, :string
    field :price_cents, :integer
    field :height_mm, :integer
    field :diameter_mm, :integer
    field :weight_g, :integer
    field :available, :boolean, default: true
    field :featured, :boolean, default: false
    field :sort_order, :integer, default: 0

    has_many :product_images, BowlSite.Catalog.ProductImage, preload_order: [asc: :position]

    timestamps(type: :utc_datetime)
  end

  def changeset(product, attrs, _metadata \\ %{}) do
    product
    |> cast(attrs, [
      :name_de, :name_en, :slug, :description_de, :description_en,
      :material, :type, :price_cents, :height_mm, :diameter_mm, :weight_g,
      :available, :featured, :sort_order
    ])
    |> validate_required([:name_de, :name_en, :price_cents])
    |> validate_number(:price_cents, greater_than: 0)
    |> validate_inclusion(:material, @valid_materials)
    |> validate_inclusion(:type, @valid_types)
    |> maybe_generate_slug()
    |> unique_constraint(:slug)
  end

  defp maybe_generate_slug(%{changes: %{name_de: name}, data: %{slug: nil}} = changeset)
       when is_binary(name) do
    put_change(changeset, :slug, slugify(name))
  end

  defp maybe_generate_slug(changeset), do: changeset

  defp slugify(name) do
    name
    |> String.downcase()
    |> String.replace(~r/[äÄ]/, "ae")
    |> String.replace(~r/[öÖ]/, "oe")
    |> String.replace(~r/[üÜ]/, "ue")
    |> String.replace(~r/[ß]/, "ss")
    |> String.replace(~r/[^a-z0-9\s-]/, "")
    |> String.replace(~r/[\s]+/, "-")
    |> String.trim("-")
  end
end
