defmodule BowlSiteWeb.LocalePlug do
  import Plug.Conn
  alias BowlSite.Locale

  def init(opts), do: opts

  def call(conn, _opts) do
    locale = get_session(conn, "locale") || Locale.default_locale()
    locale = if Locale.valid_locale?(locale), do: locale, else: Locale.default_locale()
    Gettext.put_locale(BowlSiteWeb.Gettext, locale)
    assign(conn, :locale, locale)
  end
end
