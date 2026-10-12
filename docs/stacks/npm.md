# npm

Nginx Proxy Manager, the public reverse proxy for all services.

| Item        | Value                                  |
|-------------|----------------------------------------|
| Server      | oracle                                 |
| Image       | jc21/nginx-proxy-manager:latest        |
| Container   | nginx-proxy-manager                    |
| Source      | `servers/oracle/stacks/npm`            |
| Data        | `/opt/stacks/npm/data`, `/opt/stacks/npm/letsencrypt` |
| Database    | Built-in SQLite                        |

## Ports

| Host port | Container port | Protocol | Service    | Exposure |
|-----------|----------------|----------|------------|----------|
| 80        | 80             | tcp      | HTTP       | Public   |
| 443       | 443            | tcp      | HTTPS      | Public   |
| 81        | 81             | tcp      | Admin UI   | VPN      |

## Volumes

| Host           | Container        | Purpose                 |
|----------------|------------------|-------------------------|
| ./data         | /data            | Settings and proxy hosts |
| ./letsencrypt  | /etc/letsencrypt | SSL certificates        |

## Setup

1. Open `http://<oracle netbird ip>:81`
2. Log in with the default account and change it right away
3. Add proxy hosts, see [netbird](netbird.md) for the Netbird domain

## Proxy hosts

| Domain               | Forward to                 | Notes                     |
|----------------------|----------------------------|---------------------------|
| `NETBIRD_DOMAIN`     | oracle 8081, 8082          | See [netbird](netbird.md) |
| Lab services         | `<server netbird ip>:<port>` | Requires Netbird client on oracle |

Add every new public domain to this table.

## Notes

- Back up `data` and `letsencrypt`
- Let's Encrypt needs port 80 open
