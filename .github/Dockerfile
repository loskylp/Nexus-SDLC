# Stage 1: build the static site with MkDocs
FROM python:3.12-slim AS builder

WORKDIR /build

RUN pip install --no-cache-dir \
    mkdocs-material==9.5.* \
    pymdown-extensions

# Copy config and source docs
COPY .github/mkdocs.yml mkdocs.yml
COPY docs_src/ docs_src/
COPY .github/docs-assets/ docs_src/

RUN mkdocs build

# Stage 2: serve with nginx
FROM nginx:1.27-alpine

COPY --from=builder /build/site /usr/share/nginx/html

# Custom nginx config: serve pre-built static files, handle clean URLs
COPY .github/nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
