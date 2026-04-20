alias BowlSite.{Accounts, Content}

# ----- Admin user -----
admin_email = System.get_env("ADMIN_EMAIL", "admin@example.com")
admin_password = System.get_env("ADMIN_PASSWORD", "changeme_please_123!")

case Accounts.get_user_by_email(admin_email) do
  nil ->
    {:ok, _user} = Accounts.register_user(%{email: admin_email, password: admin_password})
    IO.puts("Admin user created: #{admin_email}")

  _user ->
    IO.puts("Admin user already exists: #{admin_email}")
end

# ----- Static pages -----
pages = [
  %{
    slug: "imprint",
    title_de: "Impressum",
    title_en: "Imprint",
    body_de: """
    <h2>Angaben gemäß § 5 TMG</h2>
    <p>Tomke Reibisch<br>
    Musterstraße 1<br>
    12345 Musterstadt</p>

    <h2>Kontakt</h2>
    <p>E-Mail: kontakt@beispiel.de</p>

    <h2>Haftungsausschluss</h2>
    <p>Diese Seite wird als privates Hobby-Projekt betrieben.</p>
    """,
    body_en: """
    <h2>Legal notice</h2>
    <p>Tomke Reibisch<br>
    Musterstraße 1<br>
    12345 Musterstadt, Germany</p>

    <h2>Contact</h2>
    <p>Email: kontakt@beispiel.de</p>

    <p>This site is run as a private hobby project.</p>
    """,
    published: true
  },
  %{
    slug: "faq",
    title_de: "Häufige Fragen",
    title_en: "FAQ",
    body_de: """
    <h2>Wie kann ich ein Stück kaufen?</h2>
    <p>Schreib mir einfach eine E-Mail — ich melde mich so schnell wie möglich.</p>

    <h2>Sind die Stücke spülmaschinenfest?</h2>
    <p>Nein, handgedrechselte Holzobjekte sollten nur von Hand gewaschen werden.</p>

    <h2>Kann ich ein individuelles Stück in Auftrag geben?</h2>
    <p>Ja, bei Interesse einfach anfragen!</p>
    """,
    body_en: """
    <h2>How can I buy a piece?</h2>
    <p>Just send me an email — I'll get back to you as soon as possible.</p>

    <h2>Are the pieces dishwasher-safe?</h2>
    <p>No, hand-turned wooden objects should only be washed by hand.</p>

    <h2>Can I commission a custom piece?</h2>
    <p>Yes, feel free to ask!</p>
    """,
    published: true
  }
]

Enum.each(pages, fn attrs ->
  case Content.get_page_by_slug(attrs.slug) do
    {:error, :not_found} ->
      {:ok, _} = Content.create_static_page(attrs)
      IO.puts("Created page: /#{attrs.slug}")

    {:ok, _} ->
      IO.puts("Page already exists: /#{attrs.slug}")
  end
end)
