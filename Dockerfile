# Build stage
FROM --platform=$BUILDPLATFORM postgis/postgis:16-3.4-alpine AS builder

ARG CITUS_VERSION
ARG PGVECTOR_VERSION

# Install build dependencies
RUN apk add --no-cache --virtual .build-deps \
    build-base \
    ca-certificates \
    clang15 \
    curl \
    curl-dev \
    icu-dev \
    krb5-dev \
    libxml2-dev \
    libxslt-dev \
    llvm \
    llvm15-dev \
    lz4-dev \
    openssl-dev \
    zstd-dev

# Set up cross-compilation environment and install extensions
ADD extensions.sh /tmp/
RUN cd /tmp && bash extensions.sh && rm extensions.sh

# Final stage
FROM postgis/postgis:16-3.4-alpine

# Copy extensions from builder stage
COPY --from=builder /usr/local/lib/postgresql/*.so /usr/local/lib/postgresql/
COPY --from=builder /usr/local/share/postgresql/extension /usr/local/share/postgresql/extension

# Add Citus to default PostgreSQL config
RUN echo "shared_preload_libraries='citus'" >> /usr/local/share/postgresql/postgresql.conf.sample

# Add script to create Citus extension after initdb
RUN echo "CREATE EXTENSION IF NOT EXISTS citus;" > /docker-entrypoint-initdb.d/001-create-citus-extension.sql

# Entrypoint unsets PGPASSWORD, but Citus needs it to connect to workers
RUN sed "/unset PGPASSWORD/d" -i /usr/local/bin/docker-entrypoint.sh

# Add lz4 and zstd Citus dependencies
RUN apk add --no-cache zstd zstd-libs lz4 lz4-libs
