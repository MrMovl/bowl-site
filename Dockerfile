# ---- Stage 1: build ----
FROM elixir:1.17-alpine AS build

RUN apk add --no-cache \
  build-base \
  git \
  nodejs \
  npm \
  imagemagick

WORKDIR /app

RUN mix local.hex --force && mix local.rebar --force

ENV MIX_ENV=prod

# Fetch and compile Elixir deps
COPY mix.exs mix.lock ./
RUN mix deps.get --only prod
RUN mix deps.compile

# Install npm packages if assets/package.json exists (needed for Backpex / Alpine.js)
COPY assets/package.json assets/package-lock.json* assets/
RUN if [ -f assets/package.json ]; then npm install --prefix assets --no-save; fi

# Copy application source
COPY . .

# Compile assets
RUN mix assets.deploy

# Compile app and create release
RUN mix compile
RUN mix release

# ---- Stage 2: runtime ----
FROM alpine:3.19 AS app

RUN apk add --no-cache \
  libstdc++ \
  openssl \
  ncurses-libs \
  imagemagick

WORKDIR /app

RUN mkdir -p priv/static/uploads

COPY --from=build /app/_build/prod/rel/bowl_site ./

COPY docker-entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 4000

ENV PHX_SERVER=true

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["/app/bin/bowl_site", "start"]
