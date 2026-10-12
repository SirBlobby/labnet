# authentik

Authentik identity provider for single sign-on across lab services.

| Item        | Value                                  |
|-------------|----------------------------------------|
| Server      | oracle                                 |
| Images      | ghcr.io/goauthentik/server:`AUTHENTIK_TAG`, postgres:16 |
| Containers  | authentik-server, authentik-worker, authentik-postgres |
| Source      | `servers/oracle/stacks/authentik`      |
| Data        | `/opt/stacks/authentik/data`           |
| Secrets     | `/opt/stacks/authentik/.env`           |
| Database    | Own Postgres inside the stack          |

## Ports

| Host port | Container        | Container port | Protocol | Service        | Exposure |
|-----------|------------------|----------------|----------|----------------|----------|
| 8083      | authentik-server | 9000           | tcp      | Web UI and API | Local    |

## Volumes

| Host               | Container                 | Purpose                    |
|--------------------|---------------------------|----------------------------|
| ./data/postgres    | /var/lib/postgresql/data  | Postgres data              |
| ./data/authentik   | /data                     | Media and uploaded files   |
| ./certs            | /certs                    | Certificates for the worker |
| ./custom-templates | /templates                | Custom templates           |
| ./blueprints       | /blueprints/custom        | Blueprints applied on start |

## Environment

| Variable                        | Description                                         |
|---------------------------------|-----------------------------------------------------|
| AUTHENTIK_TAG                   | Image version, `2026.8.3`                           |
| AUTHENTIK_SECRET_KEY            | Cookie signing key, never change it after install   |
| AUTHENTIK_POSTGRESQL__PASSWORD  | Password for the `authentik` Postgres role          |
| AUTHENTIK_BOOTSTRAP_PASSWORD    | Password for `akadmin`, only read on the first start |
| NETBIRD_OIDC_CLIENT_SECRET      | Client secret of the Netbird provider               |

Secrets are generated on the first deploy and kept in `.env`.

## Blueprints

| File                      | Creates                                                       |
|---------------------------|---------------------------------------------------------------|
| `blueprints/netbird.yaml` | OAuth2 provider and application `netbird` for the Netbird login |

The Netbird provider uses client ID `netbird`, the secret from `NETBIRD_OIDC_CLIENT_SECRET` and the redirect URL `https://<NETBIRD_DOMAIN>/oauth2/callback`. See [netbird](netbird.md) for the Netbird side.

Blueprints are applied when the worker starts and again every hour. On the very first start the Netbird blueprint can fail because the default flows do not exist yet. Check it under Customization, Blueprints in the admin UI and apply it again there.

## Memory

oracle has 951 MiB of memory and the OS uses about 350 MiB, so the stack is capped and tuned to leave room for NPM and Netbird.

| Container          | Memory limit | Memory and swap limit | Tuning                       |
|--------------------|--------------|-----------------------|------------------------------|
| authentik-server   | 256 MB       | 1 GB                  | `AUTHENTIK_WEB__WORKERS=1`   |
| authentik-worker   | 128 MB       | 768 MB                | `AUTHENTIK_WORKER__THREADS=1` |
| authentik-postgres | 64 MB        | 256 MB                | `shared_buffers=32MB`        |

Authentik recommends 2 GB of memory. Here it runs partly from the swap file, so the first start and logins are slow. Check usage with `docker stats`.

## NPM proxy host

Create a proxy host for `AUTHENTIK_DOMAIN` with SSL, HTTP/2 and websockets enabled. Paste `/opt/stacks/npm/proxy-hosts/authentik.conf` in the Advanced tab, see [npm](npm.md).

| Location | Forward to        | Scheme |
|----------|-------------------|--------|
| `/`      | 172.17.0.1:8083   | http   |

## Setup

1. Point a DNS A record for `AUTHENTIK_DOMAIN` to the oracle public IP
2. Check `AUTHENTIK_DOMAIN` in `servers/oracle/server.env` (`auth.autonomousrobotics.club`)
3. Run `install.sh` or `update.sh` on oracle
4. Add the NPM proxy host
5. Read `AUTHENTIK_BOOTSTRAP_PASSWORD` from `/opt/stacks/authentik/.env`
6. Open `https://<AUTHENTIK_DOMAIN>` and log in as `akadmin`
7. Change the `akadmin` password and add your own admin user
8. Check that the Netbird blueprint is applied, then add Authentik in Netbird, see [netbird](netbird.md)

## Backups

```
docker exec authentik-postgres pg_dump -U authentik authentik > authentik.sql
```

Back up `/opt/stacks/authentik/.env` and `/opt/stacks/authentik/data/authentik` as well.

## Notes

- Authentik keeps its own Postgres on oracle, so logins do not depend on the VPN or the database on asrc
- Changing `AUTHENTIK_POSTGRESQL__PASSWORD` in `.env` does not change the role password in an existing database
- Authentik is pinned to a version, the `latest` tag is frozen at 2025.2 and must not be used. To upgrade, read the release notes, change `AUTHENTIK_TAG` in `/opt/stacks/authentik/.env` and run `update.sh`
- Keep port 8083 closed in the security list, all traffic goes through NPM
