# immich

Self hosted photo and video library with phone backup, face recognition and search.

| Item        | Value                                  |
|-------------|----------------------------------------|
| Server      | ugreen                                 |
| Version     | `v3.4.2`, pinned in `compose.yaml`     |
| Containers  | immich-server, immich-machine-learning, immich-redis, immich-postgres |
| Source      | `servers/ugreen/stacks/immich`         |
| Data        | `/volume1/docker/stacks/immich/data`   |
| Secrets     | `/volume1/docker/stacks/immich/.env`   |
| Database    | Own Postgres inside the stack          |

Immich needs Postgres with the VectorChord extension, so it keeps its own database (`ghcr.io/immich-app/postgres`) instead of using the central [database](database.md). Its Valkey is also inside the stack.

## Ports

| Host port                    | Container     | Container port | Protocol | Service          |
|------------------------------|---------------|----------------|----------|------------------|
| `IMMICH_BIND_ADDRESS`:2283   | immich-server | 2283           | tcp      | Web UI, API, app |

## Volumes

| Host                 | Container                | Purpose                        |
|----------------------|--------------------------|--------------------------------|
| `UPLOAD_LOCATION`    | /data                    | Photos, videos, thumbnails     |
| `DB_DATA_LOCATION`   | /var/lib/postgresql/data | Immich database                |
| ./data/model-cache   | /cache                   | Machine learning models        |

## Environment

Set in `/volume1/docker/stacks/immich/.env`. Values already in that file are kept on every update.

| Variable          | Default            | Description                                               |
|-------------------|--------------------|-----------------------------------------------------------|
| UPLOAD_LOCATION   | `./data/library`   | Where photos are stored. Can point to a shared folder like `/volume1/Photos` |
| DB_DATA_LOCATION  | `./data/postgres`  | Database files, must be on a local disk, not a network share |
| DB_STORAGE_TYPE   | `HDD`              | Set to `SSD` if the storage pool is on SSDs               |
| TZ                | `America/New_York` | Time zone used for photo dates                            |
| DB_PASSWORD       | generated          | Password for the Immich database                          |

`IMMICH_BIND_ADDRESS` is set in `servers/ugreen/server.env`, see [VPN access](../vpn-access.md).

## Setup

1. Run `install.sh ugreen` or `update.sh` on ugreen. The first start pulls about 2 GB of images and runs database migrations, the setup hook waits up to 5 minutes for Immich to be healthy
2. Open `http://<ugreen ip>:2283` and create the admin account. The first account becomes the admin, do this right away
3. In Administration, Settings, Server, set External Domain to the address people use, for example `http://100.82.4.126:2283`
4. Install the Immich app on phones, use the same server URL, and turn on backup

To move the library to an existing shared folder, set `UPLOAD_LOCATION` in `.env` before the first start, then run `update.sh`.

## Hardware acceleration

The default is CPU only. UGREEN DXP models have Intel CPUs, so machine learning can use OpenVINO and video transcoding can use Quick Sync. See the Immich docs for [ML acceleration](https://docs.immich.app/features/ml-hardware-acceleration) and [transcoding](https://docs.immich.app/features/hardware-transcoding). Both need `/dev/dri` passed into the containers in `compose.yaml`.

## Updating

Immich is pinned to one version because releases can include breaking changes. To update:

1. Read the [release notes](https://github.com/immich-app/immich/releases) for every version in between
2. Change the tag of `immich-server` and `immich-machine-learning` in `compose.yaml`
3. Compare with the official `docker-compose.yml` of the new release, the Postgres and Valkey images may change too
4. Push, then run `update.sh` on ugreen

## Backups

Back up the library folder and a database dump:

```
docker exec immich-postgres pg_dumpall -U postgres > immich.sql
```

Immich also writes a daily database dump to `UPLOAD_LOCATION/backups`.

## Notes

- Not public by default. To share albums publicly, add an NPM proxy host for a domain like `photos.autonomousrobotics.club` that forwards to `100.82.4.126:2283`, see [Network](../network.md)
- Uploads over the VPN go through the Netbird relay when a direct connection fails, so large backups are faster on the LAN
