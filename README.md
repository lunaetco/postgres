# Luna & Co. PostgreSQL

PostgreSQL Docker image with the following extensions installed.

- [PostgreSQL](https://www.postgresql.org)
- [PostGIS](https://postgis.net)
- [Citus](https://www.citusdata.com)
- [pgvector](https://github.com/pgvector/pgvector)

## Building

Native platform.

```sh
docker build -t postgres .
```

[Multi-platform](https://docs.docker.com/build/building/multi-platform/).

```sh
docker run --privileged --rm tonistiigi/binfmt --install qemu-aarch64
```

```sh
docker buildx create --name buildx --use
```

```sh
docker buildx build --platform linux/amd64,linux/arm64 -t lunaetco/postgres --push .
```
