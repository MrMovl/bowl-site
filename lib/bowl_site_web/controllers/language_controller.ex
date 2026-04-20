defmodule BowlSiteWeb.LanguageController do
  use BowlSiteWeb, :controller

  alias BowlSite.Locale

  def set(conn, %{"locale" => locale}) do
    locale = if Locale.valid_locale?(locale), do: locale, else: Locale.default_locale()
    return_to = get_session(conn, :return_to) || conn.params["return_to"] || "/"

    conn
    |> put_session("locale", locale)
    |> redirect(to: return_to)
  end

  def set(conn, _params) do
    redirect(conn, to: "/")
  end
end
