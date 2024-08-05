#!/usr/bin/env bash

set -eux -o pipefail

BUILDPLATFORM="${BUILDPLATFORM:=}"
TARGETPLATFORM="${TARGETPLATFORM:=}"
CITUS_VERSION="${CITUS_VERSION:=12.1.5}"
PGVECTOR_VERSION="${PGVECTOR_VERSION:=0.7.4}"

# Set up cross-compilation environment
case "${TARGETPLATFORM}" in
"linux/amd64") ARCH="x86_64" ;;
"linux/arm64") ARCH="aarch64" ;;
"") ;;
*)
    echo "Unsupported architecture: ${TARGETPLATFORM}"
    exit 1
    ;;
esac

if [ "$BUILDPLATFORM" != "$TARGETPLATFORM" ]; then
    apk add --no-cache gcc-${ARCH}-alpine-linux-musl g++-${ARCH}-alpine-linux-musl
    export CC=${ARCH}-alpine-linux-musl-gcc
    export CXX=${ARCH}-alpine-linux-musl-g++
fi

# Download and install Citus
curl -sfLO "https://github.com/citusdata/citus/archive/v${CITUS_VERSION}.tar.gz"
tar xzf "v${CITUS_VERSION}.tar.gz"
(cd "citus-${CITUS_VERSION}" && ./configure --with-security-flags && make install)
rm -rf "citus-${CITUS_VERSION}" "v${CITUS_VERSION}.tar.gz"

# Download and install pgvector
curl -sfLO "https://github.com/pgvector/pgvector/archive/refs/tags/v${PGVECTOR_VERSION}.tar.gz"
tar xzf "v${PGVECTOR_VERSION}.tar.gz"
(cd "pgvector-${PGVECTOR_VERSION}" && make install)
rm -rf "pgvector-${PGVECTOR_VERSION}" "v${PGVECTOR_VERSION}.tar.gz"
