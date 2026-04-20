defmodule BowlSite.Repo.Migrations.CreateProducts do
  use Ecto.Migration

  def change do
    create table(:products) do
      add :name_de, :string, null: false
      add :name_en, :string, null: false
      add :slug, :string, null: false
      add :description_de, :text
      add :description_en, :text
      add :material, :string
      add :type, :string
      add :price_cents, :integer, null: false
      add :height_mm, :integer
      add :diameter_mm, :integer
      add :weight_g, :integer
      add :available, :boolean, null: false, default: true
      add :featured, :boolean, null: false, default: false
      add :sort_order, :integer, default: 0

      timestamps(type: :utc_datetime)
    end

    create unique_index(:products, [:slug])
    create index(:products, [:material, :type, :available, :price_cents])
  end
end
