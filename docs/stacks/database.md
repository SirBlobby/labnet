# database

Central Postgres and Valkey for all services.

| Item        | Value                                  |
|-------------|----------------------------------------|
| Server      | asrc                                   |
| Images      | postgres:16, valkey/valkey:8-bookworm  |
| Containers  | core-postgres, core-valkey             |
| Network     | core-data (external)                   |
| Source      | `servers/asrc/stacks/database`         |
| Data        | `/opt/stacks/database/data`            |
| Secrets     | `/opt/stacks/database/.env`            |

## Ports

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
| SERVICE_DATABASES     | Comma separated list of service databases      |
| `<NAME>_DB_PASSWORD`  | Password for each service role                 |

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
| asrc stacks       | `postgres://<name>:<password>@core-postgres:5432/<name>`        | `redis://:<password>@core-valkey:6379`           |
| Other servers     | `postgres://<name>:<password>@<asrc netbird ip>:5432/<name>`    | `redis://:<password>@<asrc netbird ip>:6379`     |

Stacks on asrc join the network with:

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

- Netbird and NPM do not use this database
- Changing a password in `.env` and running `update.sh` updates the role password
