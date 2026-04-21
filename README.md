# Bowl Site

Bilingual (DE/EN) portfolio shop for handmade lathe-turned objects. Built with Phoenix + LiveView, Backpex admin panel, and Waffle for image uploads. No payment processing — visitors contact the maker directly to buy.

---

## Fresh pull — getting started

### Prerequisites

| Tool | Min version | Notes |
|---|---|---|
| Docker | 24+ | Engine + CLI |
| Docker Compose | v2 (plugin) | `docker compose` (no hyphen) |
| Git | any | |

No local Elixir, Erlang, Node, or PostgreSQL needed — everything runs in containers.

---

### 1. Clone

```bash
git clone <repo-url> bowl-site
cd bowl-site
```

---

### 2. Configure environment

```bash
cp .env.example .env
```

Open `.env` and fill in the values:

| Variable | What to set |
|---|---|
| `POSTGRES_USER` | any username, e.g. `bowl_site` |
| `POSTGRES_PASSWORD` | a strong password |
| `POSTGRES_DB` | e.g. `bowl_site_prod` |
| `SECRET_KEY_BASE` | run `mix phx.gen.secret` locally, or generate 64+ random chars |
| `PHX_HOST` | your domain (no `https://`, no trailing slash), e.g. `yourdomain.com` |
| `ADMIN_EMAIL` | email for the admin account created on first boot |
| `ADMIN_PASSWORD` | at least 12 characters |

For **local development** you can leave all values as-is from the example — the dev compose file uses hardcoded dev credentials and doesn't read `.env`.

---

### 3. Install Backpex JS dependencies (one-time)

Backpex requires Alpine.js and daisyUI via npm. This step is needed before the first `docker compose up`:

```bash
# If you have Node locally:
cd assets && npm install && cd ..

# Or run it inside a throwaway container:
docker run --rm -v "$PWD/assets:/assets" -w /assets node:20-alpine npm install
```

See `backpex-howto.md` for full details on the Backpex integration.

---

### 4. Start the development environment

```bash
docker compose up --build
```

On first run this will:
- Pull/build the dev image (Elixir + Node + ImageMagick)
- Start PostgreSQL
- Run `mix deps.get`
- Create and migrate the database
- Seed the admin user and sample static pages
- Start the Phoenix server with live reload

**Access the app:**

| URL | What |
|---|---|
| http://localhost:4000 | Public site |
| http://localhost:4000/shop | Product gallery |
| http://localhost:4000/admin/login | Admin login |
| http://localhost:4000/admin | Admin dashboard (after login) |

**Admin credentials in dev:** set via `ADMIN_EMAIL` / `ADMIN_PASSWORD` in `priv/repo/seeds.exs` (defaults match `.env.example`).

---

### 5. Day-to-day development

The source code is volume-mounted into the container — edit files locally and Phoenix reloads automatically.

```bash
# Start (foreground, shows logs):
docker compose up

# Start (background):
docker compose up -d

# Stop:
docker compose down

# Tail logs:
docker compose logs -f app

# Run a mix command inside the container:
docker compose exec app mix ecto.migrate
docker compose exec app mix test

# Open an IEx console:
docker compose exec app iex -S mix
```

---

### 6. Database management

```bash
# Reset the database (drop + recreate + seed):
docker compose exec app mix ecto.reset

# Run pending migrations only:
docker compose exec app mix ecto.migrate

# Roll back one migration:
docker compose exec app mix ecto.rollback
```

---

### 7. Adding content (admin CMS)

1. Log in at `/admin/login`
2. **Products** — `/admin/products` — Backpex list view with search and delete. Click "Neues Produkt" to create; the create/edit form is a custom LiveView with multi-image upload.
3. **Static pages** — `/admin/pages` — Backpex full CRUD. FAQ and Imprint are seeded on first boot. Set `published: false` to hide a page instead of deleting it.

---

## Production deployment (self-hosted VPS)

### Prerequisites on the server

```bash
# Ubuntu/Debian
apt install docker.io docker-compose-plugin certbot python3-certbot-nginx
```

### 1. Upload the project

```bash
git clone <repo-url> /opt/bowl-site
cd /opt/bowl-site
cp .env.example .env
# Edit .env with real values — SECRET_KEY_BASE, domain, admin creds, etc.
```

### 2. Configure Nginx

Edit `nginx/default.conf` and replace `yourdomain.com` with your actual domain in both places.

### 3. Obtain an SSL certificate

```bash
# Start nginx temporarily (HTTP only) to pass the ACME challenge:
docker compose -f docker-compose.prod.yml --profile certbot up certbot

# Then bring nginx up normally:
docker compose -f docker-compose.prod.yml up -d nginx
```

Or if you prefer the host certbot:

```bash
certbot --nginx -d yourdomain.com
```

### 4. Start production

```bash
docker compose -f docker-compose.prod.yml up -d --build
```

On first boot the app container runs `BowlSite.Release.migrate/0` and `BowlSite.Release.seed/0` automatically before starting Phoenix.

### 5. Persistent uploads

The `uploads` named Docker volume stores product images across container restarts and deploys. It is mounted at `/app/priv/static/uploads` inside the app container and served directly by Nginx at `/uploads/`.

### 6. Updates

```bash
cd /opt/bowl-site
git pull
docker compose -f docker-compose.prod.yml up -d --build
```

Migrations run automatically on container start via the entrypoint script.

---

## Project structure

```
lib/
  bowl_site/
    accounts/          # phx.gen.auth — User, Accounts context
    catalog/           # Products, ProductImages, filter pipeline
    content/           # StaticPages context
    locale.ex          # t(record, field, locale) bilingual helper
    release.ex         # migrate/0 and seed/0 for production entrypoint
  bowl_site_web/
    live/
      admin/           # Admin LiveViews (dashboard, product form, Backpex resources)
    controllers/       # PageController (home), LanguageController, auth controllers
    locale_plug.ex     # Reads locale from session, assigns @locale, sets Gettext locale
priv/
  repo/migrations/     # Ecto migrations
  repo/seeds.exs       # Admin user + static pages (idempotent)
  static/uploads/      # Waffle upload target (gitignored)
assets/
  js/app.js            # Phoenix LiveView + Alpine.js + Backpex hooks
  css/app.css          # Tailwind entry point
  tailwind.config.js   # Tailwind config (includes Backpex content paths)
nginx/
  default.conf         # Nginx reverse proxy config
```

---

## Language / i18n

- Default language: **German (DE)**
- Toggle: POST `/language` with `locale=en` or `locale=de` (rendered as a button in the nav)
- Language stored in the session — no URL change, no reload of assets
- UI strings: Gettext `.po` files in `priv/gettext/`
- Content (names, descriptions, page bodies): dual DB fields (`name_de`/`name_en` etc.)

---

## Troubleshooting

**`mix deps.get` fails in Docker:**
The dev container needs internet access to fetch Hex packages. Check your Docker network settings.

**Admin login redirects back to login:**
The admin account is created by seeds. Run:
```bash
docker compose exec app mix run priv/repo/seeds.exs
```

**Images not showing:**
In dev, Waffle stores uploads at `priv/static/uploads/` which is gitignored and may not exist. It is created automatically on first upload. In production, verify the `uploads` Docker volume is mounted correctly.

**Backpex pages throw JS errors:**
Alpine.js and daisyUI must be installed. Run `npm install` in `assets/` and rebuild: `docker compose exec app mix assets.build`. See `backpex-howto.md`.

**Port 4000 already in use:**
Set `PORT=4001` in the environment before `docker compose up`.
