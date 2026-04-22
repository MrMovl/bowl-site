# bowl-site

Handmade woodwork gallery with a self-hosted CMS. Built with Next.js 15 + Payload CMS v3 + PostgreSQL.

## Local development

### Prerequisites

- Docker

### Steps

**1. Create your `.env` file**

```bash
cp .env.example .env
```

The defaults work out of the box. Change `PAYLOAD_SECRET` and `POSTGRES_PASSWORD` before going to production.

**2. Start everything**

```bash
docker compose up
```

This starts PostgreSQL and the Next.js dev server with hot reload. Source code changes are reflected immediately without rebuilding the image.

**3. Create your admin account**

Open [http://localhost:3000/admin](http://localhost:3000/admin) and create your first user. Payload runs database migrations automatically on first startup.

**4. Seed content for FAQ and legal pages**

The `/faq` and `/legal` pages render content from the **Pages** collection. In the admin panel, create two entries:

- slug: `faq`, title: `FAQ`
- slug: `legal`, title: `Legal notice`

---

## Production deployment

`docker-compose.override.yml` is only loaded automatically for local development. For production, skip it and build the optimised image explicitly:

```bash
docker compose -f docker-compose.yml up --build
```

Put a reverse proxy (nginx, Caddy) in front of port 3000 for TLS.

---

## Project structure

```
src/
  app/
    (frontend)/       # Public site: gallery, product detail, FAQ, legal
    (payload)/admin/  # Payload CMS admin panel
    api/[...payload]/ # Payload REST API
  collections/        # TypeScript schemas: Products, Media, Pages, Users
  components/         # Shared React components
  payload.config.ts   # CMS configuration
```

## Useful commands

| Command | What it does |
|---|---|
| `docker compose up` | Start everything for local dev (hot reload) |
| `docker compose up --build` | Rebuild image after changing dependencies |
| `docker compose down` | Stop all containers |
| `docker compose down -v` | Stop and delete volumes (wipes database and media) |
| `docker compose logs -f app` | Tail app logs |
| `npm run generate:types` | Regenerate `src/payload-types.ts` after schema changes |
