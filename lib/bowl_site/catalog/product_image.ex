defmodule BowlSite.Catalog.ProductImage do
  use Ecto.Schema
  import Ecto.Changeset
  import Waffle.Ecto.Changeset

  alias BowlSite.Catalog.Uploaders.ProductImage, as: ProductImageUploader

  schema "product_images" do
    field :filename, ProductImageUploader.Type
    field :position, :integer, default: 0
    field :alt_text, :string

    belongs_to :product, BowlSite.Catalog.Product

    timestamps(type: :utc_datetime)
  end

  def changeset(image, attrs) do
    image
    |> cast(attrs, [:position, :alt_text, :product_id])
    |> validate_required([:product_id])
    |> cast_attachments(attrs, [:filename])
  end
end
