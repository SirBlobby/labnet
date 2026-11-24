# database

Central Postgres and Valkey for all services.

| Item        | Value                                  |
|-------------|----------------------------------------|
| Server      | ugreen                                 |
| Images      | postgres:16, valkey/valkey:8-bookworm  |
| Containers  | core-postgres, core-valkey             |
| Network     | core-data (external)                   |
| Source      | `servers/ugreen/stacks/database`       |
| Data        | `/volume1/docker/stacks/database/data` |
| Secrets     | `/volume1/docker/stacks/database/.env` |

## Ports

`DATABASE_BIND_ADDRESS` is the ugreen Netbird IP, so Postgres and Valkey are reachable over the VPN only. See [VPN access](../vpn-access.md).

| Host port                       | Container     | Container port | Protocol | Service  |
|---------------------------------|---------------|----------------|----------|----------|
| `DATABASE_BIND_ADDRESS`:5432    | core-postgres | 5432           | tcp      | Postgres |
| `DATABASE_BIND_ADDRESS`:6379    | core-valkey   | 6379           | tcp      | Valkey   |

## Volumes

| Host            | Container                    | Purpose                   |
|-----------------|------------------------------|---------------------------|
| ./data/postgres | /var/lib/postgresql/data     | Postgres data             |
| ./init          | /docker-entrypoint-initdb.d  | Service database setup    |
| ./data/valkey   | /data                        | Valkey snapshots          |

## Environment

| Variable              | Description                                    |
|-----------------------|------------------------------------------------|
| POSTGRES_PASSWORD     | Password for the `postgres` superuser          |
| VALKEY_PASSWORD       | Password for Valkey                            |
| `<NAME>_DB_PASSWORD`  | Creates role and database `<name>` with this password |
| SERVICE_DATABASES     | Optional extra names, older installs still have it |

## Service databases

| Name   | Role   | Database | Password variable   |
|--------|--------|----------|---------------------|
| kaneo  | kaneo  | kaneo    | KANEO_DB_PASSWORD   |
| coder  | coder  | coder    | CODER_DB_PASSWORD   |
| postiz | postiz | postiz   | POSTIZ_DB_PASSWORD  |

Roles and databases are created after every deploy by `hooks/after-deploy.sh`. Existing ones are kept and their passwords are synced from `.env`.

## Connecting

| From              | Postgres URL                                                   | Valkey URL                                      |
|-------------------|----------------------------------------------------------------|-------------------------------------------------|
| ugreen stacks     | `postgres://<name>:<password>@core-postgres:5432/<name>`        | `redis://:<password>@core-valkey:6379`           |
| Other servers     | `postgres://<name>:<password>@100.82.4.126:5432/<name>`         | `redis://:<password>@100.82.4.126:6379`          |

Stacks on ugreen join the network with:

```yaml
networks:
  core-data:
    external: true
```

## Backups

```
docker exec core-postgres pg_dumpall -U postgres > backup.sql
```

## Notes

- Netbird, NPM and Authentik do not use this database
- Immich keeps its own Postgres, it needs the VectorChord extension, see [immich](immich.md)
- Get a password on ugreen with `sudo grep <NAME>_DB_PASSWORD /volume1/docker/stacks/database/.env`
- Moved from asrc to ugreen. If the stack ever ran on asrc, stop it there with `docker compose -f /opt/stacks/database/compose.yaml down` and move the data with `pg_dumpall`
- Changing a password in `.env` and running `update.sh` updates the role password
