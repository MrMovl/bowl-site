defmodule BowlSiteWeb.Helpers do
  alias BowlSite.Locale

  def format_price(nil), do: "—"

  def format_price(cents) when is_integer(cents) do
    euros = cents / 100
    :erlang.float_to_binary(euros, decimals: 2) |> then(&"€#{&1}")
  end

  def locale(conn_or_socket_or_assigns) do
    cond do
      is_map(conn_or_socket_or_assigns) and Map.has_key?(conn_or_socket_or_assigns, :assigns) ->
        conn_or_socket_or_assigns.assigns[:locale] || Locale.default_locale()

      is_map(conn_or_socket_or_assigns) and Map.has_key?(conn_or_socket_or_assigns, :locale) ->
        conn_or_socket_or_assigns[:locale] || Locale.default_locale()

      true ->
        Locale.default_locale()
    end
  end

  def lt(record, field, locale), do: Locale.t(record, field, locale)
end
