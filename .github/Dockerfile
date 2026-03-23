# Stage 1: build the static site with Astro + Starlight
FROM node:22-alpine AS builder

WORKDIR /build

# Copy site project files
COPY .github/site/package.json .github/site/package-lock.json ./
RUN npm ci

COPY .github/site/ ./

# docs_src is prepared by CI before the Docker build
COPY docs_src/ docs_src/

# Copy markdown content into Starlight content directories
RUN mkdir -p src/content/docs/process src/content/docs/tests && \
    cp docs_src/index.md    src/content/docs/overview.md && \
    cp docs_src/rationale.md src/content/docs/rationale.md && \
    cp docs_src/references.md src/content/docs/references.md && \
    cp -r docs_src/process/. src/content/docs/process/ && \
    cp -r docs_src/tests/.   src/content/docs/tests/

RUN npm run build

# Stage 2: serve with nginx
FROM nginx:1.27-alpine

COPY --from=builder /build/dist /usr/share/nginx/html

# Custom nginx config: serve pre-built static files, handle clean URLs
COPY .github/nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
