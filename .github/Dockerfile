# Stage 1: build the static site with Astro + Starlight
# Docs content is prepared into .github/site/src/content/docs/ by the CI workflow
# before this build runs, so COPY .github/site/ picks everything up in one step.
FROM node:22-alpine AS builder

WORKDIR /build

# Install dependencies first (cached layer if package files unchanged)
COPY .github/site/package.json .github/site/package-lock.json ./
RUN npm ci

# Copy full site source (includes pre-populated src/content/docs/)
COPY .github/site/ ./

RUN npx astro telemetry disable && npm run build

# Stage 2: serve with nginx
FROM nginx:1.27-alpine

COPY --from=builder /build/dist /usr/share/nginx/html

COPY .github/nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
