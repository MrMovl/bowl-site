defmodule BowlSite.Catalog.Uploaders.ProductImage do
  use Waffle.Definition
  use Waffle.Ecto.Definition

  @versions [:original, :large, :thumb]
  @extension_whitelist ~w(.jpg .jpeg .png .webp)

  def validate({file, _}) do
    file_extension = file.file_name |> Path.extname() |> String.downcase()
    Enum.member?(@extension_whitelist, file_extension)
  end

  def transform(:large, _) do
    {:convert, "-strip -thumbnail 1200x1200> -format jpg", :jpg}
  end

  def transform(:thumb, _) do
    {:convert, "-strip -thumbnail 400x400> -format jpg", :jpg}
  end

  def transform(:original, _), do: :noaction

  def filename(version, {_file, scope}) do
    "#{scope.id}_#{version}"
  end

  def storage_dir(_version, {_file, scope}) do
    "uploads/products/#{scope.product_id}"
  end
end
