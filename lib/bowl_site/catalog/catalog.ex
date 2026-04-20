defmodule BowlSite.Catalog do
  import Ecto.Query, warn: false
  alias BowlSite.Repo
  alias BowlSite.Catalog.{Product, ProductImage}
  alias BowlSite.Catalog.Uploaders.ProductImage, as: ProductImageUploader

  # ---------------------------------------------------------------------------
  # Public read
  # ---------------------------------------------------------------------------

  def list_products(filters \\ %{}) do
    Product
    |> filter_by_material(filters["material"])
    |> filter_by_type(filters["type"])
    |> filter_by_available(filters["available"])
    |> filter_by_price_min(filters["price_min"])
    |> filter_by_price_max(filters["price_max"])
    |> order_by([p], [asc: p.sort_order, desc: p.inserted_at])
    |> preload(product_images: ^from(i in ProductImage, order_by: [asc: i.position]))
    |> Repo.all()
  end

  def get_product!(id), do: Repo.get!(Product, id) |> Repo.preload(:product_images)

  def get_product_by_slug!(slug) do
    Repo.get_by!(Product, slug: slug)
    |> Repo.preload(product_images: from(i in ProductImage, order_by: [asc: i.position]))
  end

  def list_featured_products(limit \\ 6) do
    Product
    |> where([p], p.featured == true and p.available == true)
    |> order_by([p], [asc: p.sort_order])
    |> limit(^limit)
    |> preload(product_images: ^from(i in ProductImage, order_by: [asc: i.position]))
    |> Repo.all()
  end

  def list_materials do
    Product
    |> select([p], p.material)
    |> where([p], not is_nil(p.material))
    |> distinct(true)
    |> Repo.all()
    |> Enum.sort()
  end

  def list_types do
    Product
    |> select([p], p.type)
    |> where([p], not is_nil(p.type))
    |> distinct(true)
    |> Repo.all()
    |> Enum.sort()
  end

  def max_price_cents do
    Repo.aggregate(Product, :max, :price_cents) || 50_000
  end

  # ---------------------------------------------------------------------------
  # Admin write
  # ---------------------------------------------------------------------------

  def create_product(attrs \\ %{}) do
    %Product{}
    |> Product.changeset(attrs)
    |> Repo.insert()
  end

  def update_product(%Product{} = product, attrs) do
    product
    |> Product.changeset(attrs)
    |> Repo.update()
  end

  def delete_product(%Product{} = product) do
    Enum.each(product.product_images, &delete_product_image/1)
    Repo.delete(product)
  end

  def toggle_availability(%Product{} = product) do
    product
    |> Ecto.Changeset.change(available: !product.available)
    |> Repo.update()
  end

  def change_product(%Product{} = product, attrs \\ %{}) do
    Product.changeset(product, attrs)
  end

  # ---------------------------------------------------------------------------
  # Image management
  # ---------------------------------------------------------------------------

  def add_product_image(%Product{} = product, upload_params, attrs \\ %{}) do
    image = %ProductImage{product_id: product.id}

    image
    |> ProductImage.changeset(Map.merge(attrs, %{"product_id" => product.id}))
    |> Repo.insert()
    |> case do
      {:ok, saved_image} ->
        case ProductImageUploader.store({upload_params, saved_image}) do
          {:ok, filename} ->
            saved_image
            |> Ecto.Changeset.change(filename: filename)
            |> Repo.update()

          {:error, reason} ->
            Repo.delete(saved_image)
            {:error, reason}
        end

      error ->
        error
    end
  end

  def delete_product_image(%ProductImage{} = image) do
    ProductImageUploader.delete({image.filename, image})
    Repo.delete(image)
  end

  def reorder_images(%Product{} = product, ordered_ids) do
    ordered_ids
    |> Enum.with_index()
    |> Enum.each(fn {id, position} ->
      from(i in ProductImage, where: i.id == ^id and i.product_id == ^product.id)
      |> Repo.update_all(set: [position: position])
    end)

    :ok
  end

  def cover_image(%Product{product_images: images}) when is_list(images) do
    Enum.min_by(images, & &1.position, fn -> nil end)
  end

  def cover_image(_), do: nil

  def image_url(%ProductImage{} = image, version \\ :thumb) do
    ProductImageUploader.url({image.filename, image}, version)
  end

  # ---------------------------------------------------------------------------
  # Filter helpers (private)
  # ---------------------------------------------------------------------------

  defp filter_by_material(query, nil), do: query
  defp filter_by_material(query, ""), do: query
  defp filter_by_material(query, m), do: where(query, [p], p.material == ^m)

  defp filter_by_type(query, nil), do: query
  defp filter_by_type(query, ""), do: query
  defp filter_by_type(query, t), do: where(query, [p], p.type == ^t)

  defp filter_by_available(query, "true"), do: where(query, [p], p.available == true)
  defp filter_by_available(query, _), do: query

  defp filter_by_price_min(query, nil), do: query
  defp filter_by_price_min(query, ""), do: query

  defp filter_by_price_min(query, min) do
    case Integer.parse(min) do
      {cents, _} -> where(query, [p], p.price_cents >= ^cents)
      :error -> query
    end
  end

  defp filter_by_price_max(query, nil), do: query
  defp filter_by_price_max(query, ""), do: query

  defp filter_by_price_max(query, max) do
    case Integer.parse(max) do
      {cents, _} -> where(query, [p], p.price_cents <= ^cents)
      :error -> query
    end
  end
end
