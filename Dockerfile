FROM node:20-alpine AS base

# ---- dev (hot reload, source mounted via volume) ----
FROM base AS dev
WORKDIR /app
COPY package*.json tsconfig.json next.config.ts ./
RUN npm install
EXPOSE 3000
CMD ["npm", "run", "dev"]

# ---- deps ----
FROM base AS deps
WORKDIR /app
COPY package*.json ./
RUN npm ci

# ---- builder ----
FROM base AS builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .
ENV NEXT_TELEMETRY_DISABLED=1
RUN npm run build

# ---- runner ----
FROM base AS runner
WORKDIR /app
ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1

RUN addgroup --system --gid 1001 nodejs && \
    adduser --system --uid 1001 nextjs

COPY --from=builder /app/public ./public
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

RUN mkdir -p public/media && chown nextjs:nodejs public/media

USER nextjs
EXPOSE 3000
ENV PORT=3000
ENV HOSTNAME="0.0.0.0"

CMD ["node", "server.js"]
