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
| `NETBIRD_DOMAIN`     | 172.17.0.1:8082            | Advanced config from `proxy-hosts/netbird.conf` |
| `AUTHENTIK_DOMAIN`   | 172.17.0.1:8083            | Advanced config from `proxy-hosts/authentik.conf` |
| Lab services         | `<server netbird ip>:<port>` | Requires Netbird client on oracle |

Add every new public domain to this table.

## Proxy host config

NPM keeps proxy hosts in its own database, so they are added in the admin UI. The config for the Advanced tab is kept in `servers/oracle/stacks/npm/proxy-hosts` and copied to `/opt/stacks/npm/proxy-hosts` on every update.

For each host:

1. Add a proxy host with the domain and forward target from the table above, scheme `http`
2. Turn on Websockets Support and Block Common Exploits
3. On the SSL tab request a certificate and turn on Force SSL and HTTP/2 Support
4. On the Advanced tab paste the content of the matching file in `proxy-hosts`

`172.17.0.1` is the Docker host address, NPM reaches the other stacks through their published ports.

## Notes

- Back up `data` and `letsencrypt`
- Let's Encrypt needs port 80 open
