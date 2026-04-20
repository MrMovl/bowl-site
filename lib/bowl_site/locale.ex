defmodule BowlSite.Locale do
  @supported_locales ~w(de en)
  @default_locale "de"

  def supported_locales, do: @supported_locales
  def default_locale, do: @default_locale

  def t(record, field, locale) when is_atom(field) do
    key = :"#{field}_#{locale}"
    fallback_key = :"#{field}_#{@default_locale}"
    Map.get(record, key) || Map.get(record, fallback_key) || ""
  end

  def t(record, field, locale) when is_binary(field) do
    t(record, String.to_atom(field), locale)
  end

  def valid_locale?(locale) when is_binary(locale), do: locale in @supported_locales
  def valid_locale?(_), do: false
end
