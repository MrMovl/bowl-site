defmodule BowlSite.Repo.Migrations.CreateStaticPages do
  use Ecto.Migration

  def change do
    create table(:static_pages) do
      add :slug, :string, null: false
      add :title_de, :string, null: false
      add :title_en, :string, null: false
      add :body_de, :text, null: false, default: ""
      add :body_en, :text, null: false, default: ""
      add :meta_description_de, :string
      add :meta_description_en, :string
      add :published, :boolean, null: false, default: true

      timestamps(type: :utc_datetime)
    end

    create unique_index(:static_pages, [:slug])
  end
end
