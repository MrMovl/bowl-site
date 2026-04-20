defmodule BowlSite.Content do
  import Ecto.Query, warn: false
  alias BowlSite.Repo
  alias BowlSite.Content.StaticPage

  def list_static_pages do
    Repo.all(from p in StaticPage, order_by: [asc: p.slug])
  end

  def get_static_page!(id), do: Repo.get!(StaticPage, id)

  def get_page_by_slug!(slug) do
    Repo.get_by!(StaticPage, slug: slug, published: true)
  end

  def get_page_by_slug(slug) do
    case Repo.get_by(StaticPage, slug: slug, published: true) do
      nil -> {:error, :not_found}
      page -> {:ok, page}
    end
  end

  def create_static_page(attrs \\ %{}) do
    %StaticPage{}
    |> StaticPage.changeset(attrs)
    |> Repo.insert()
  end

  def update_static_page(%StaticPage{} = page, attrs) do
    page
    |> StaticPage.changeset(attrs)
    |> Repo.update()
  end

  def change_static_page(%StaticPage{} = page, attrs \\ %{}) do
    StaticPage.changeset(page, attrs)
  end
end
