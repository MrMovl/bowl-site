# bowl-site

Handmade woodwork gallery with a self-hosted CMS. Built with Next.js 15 + Payload CMS v3 + PostgreSQL.

## Local development

### Prerequisites

- Node.js 20+
- Docker (for the database)

### Steps

**1. Install dependencies**

```bash
npm install
```

**2. Create your `.env` file**

```bash
cp .env.example .env
```

The defaults work for local dev as-is. Change `PAYLOAD_SECRET` to any random string of 32+ characters before going to production.

**3. Start the database**

```bash
docker compose up db -d
```

This starts PostgreSQL on `localhost:5432`. Wait a few seconds for it to be ready, or check with:

```bash
docker compose ps
```

**4. Start the dev server**

```bash
npm run dev
```

Payload runs database migrations automatically on first startup.

**5. Create your admin account**

Open [http://localhost:3000/admin](http://localhost:3000/admin) and create your first user. This is the account you'll use to manage products and pages.

### Seed content for FAQ and legal pages

The FAQ and legal pages render content from the `Pages` collection. After creating your admin account, go to **Pages** in the admin panel and create two entries:

- slug: `faq`, title: `FAQ`, content: your FAQ text
- slug: `legal`, title: `Legal`, content: your legal notice

---

## Full Docker deployment

For running everything in containers (e.g. on a VPS):

**1.** In `.env`, swap the `DATABASE_URI` hostname from `localhost` to `db`:

```
DATABASE_URI=postgresql://postgres:changeme@db:5432/bowlsite
```

**2.** Build and start:

```bash
docker compose up --build
```

The app will be available on port 3000. Put a reverse proxy (nginx, Caddy) in front of it for TLS.

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
| `npm run dev` | Start dev server with hot reload |
| `npm run build` | Production build |
| `npm run generate:types` | Regenerate `src/payload-types.ts` after schema changes |
| `docker compose up db -d` | Start only the database |
| `docker compose down` | Stop all containers |
| `docker compose down -v` | Stop and delete volumes (wipes database) |
