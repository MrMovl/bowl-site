defmodule BowlSite.Repo.Migrations.CreateProductImages do
  use Ecto.Migration

  def change do
    create table(:product_images) do
      add :product_id, references(:products, on_delete: :delete_all), null: false
      add :filename, :string
      add :position, :integer, null: false, default: 0
      add :alt_text, :string

      timestamps(type: :utc_datetime)
    end

    create index(:product_images, [:product_id])
    create index(:product_images, [:product_id, :position])
  end
end
