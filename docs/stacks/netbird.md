# netbird

Self hosted Netbird VPN server and dashboard.

| Item        | Value                                  |
|-------------|----------------------------------------|
| Server      | oracle                                 |
| Images      | netbirdio/netbird-server:latest, netbirdio/dashboard:latest |
| Containers  | netbird-server, netbird-dashboard      |
| Source      | `servers/oracle/stacks/netbird`        |
| Data        | `/opt/stacks/netbird/data`             |
| Database    | Built-in SQLite                        |

## Ports

| Host port | Container         | Container port | Protocol | Service                   |
|-----------|-------------------|----------------|----------|---------------------------|
| 8081      | netbird-server    | 80             | tcp      | API, gRPC, relay, OAuth   |
| 3478      | netbird-server    | 3478           | udp      | STUN                      |
| 8082      | netbird-dashboard | 80             | tcp      | Dashboard                 |

## Volumes

| Host            | Container               | Purpose        |
|-----------------|-------------------------|----------------|
| ./data          | /var/lib/netbird        | Server data    |
| ./config.yaml   | /etc/netbird/config.yaml | Server config |

## Files

| File                | Created from               | Notes                              |
|---------------------|----------------------------|------------------------------------|
| config.yaml         | config.yaml.example        | Auth secret and encryption key generated once |
| dashboard.env       | dashboard.env.example      | Dashboard settings                 |

Both files are created once and never overwritten. Edit them in `/opt/stacks/netbird` on oracle.

## NPM proxy host

Create a proxy host for `NETBIRD_DOMAIN` that forwards to `172.17.0.1:8082`, with SSL, HTTP/2 and websockets enabled. Paste `/opt/stacks/npm/proxy-hosts/netbird.conf` in the Advanced tab, see [npm](npm.md).

| Location                          | Forward to          | Scheme |
|-----------------------------------|---------------------|--------|
| `/`                               | 172.17.0.1:8082     | http   |
| `/api/`, `/oauth2/`               | 172.17.0.1:8081     | http   |
| `/relay`, `/ws-proxy/`            | 172.17.0.1:8081     | http, websocket |
| `/signalexchange.SignalExchange/` | 172.17.0.1:8081     | grpc   |
| `/management.ManagementService/`  | 172.17.0.1:8081     | grpc   |

## Setup

1. Check `NETBIRD_DOMAIN` in `servers/oracle/server.env` before the first install (`netbird.autonomousrobotics.club`)
2. Run `install.sh`
3. Review `config.yaml` and `dashboard.env` against the Netbird self hosting docs
4. Restart the stack in Dockge
5. Add the NPM proxy host
6. Open `https://<NETBIRD_DOMAIN>` and create the admin account

## Login with Authentik

Netbird keeps its built-in login and Authentik is added as an extra identity provider. The Authentik side is created by the blueprint in the [authentik](authentik.md) stack.

1. In the Netbird dashboard open Settings, Identity Providers, Add Identity Provider
2. Fill in the form:

| Field         | Value                                                   |
|---------------|---------------------------------------------------------|
| Type          | Generic OIDC                                            |
| Name          | Authentik                                               |
| Client ID     | `netbird`                                               |
| Client Secret | `NETBIRD_OIDC_CLIENT_SECRET` from `/opt/stacks/authentik/.env` |
| Issuer        | `https://<AUTHENTIK_DOMAIN>/application/o/netbird/`     |

3. Check that the Redirect URL shown by Netbird is `https://<NETBIRD_DOMAIN>/oauth2/callback`. If it is different, change it in `servers/oracle/stacks/authentik/blueprints/netbird.yaml`
4. Click Add Provider
5. Log out, the login page now has an Authentik button

The built-in admin account keeps working when Authentik is down.

## Notes

- Changing `NETBIRD_DOMAIN` after the first install does not update `config.yaml` or `dashboard.env`, edit them by hand
- Back up `/opt/stacks/netbird/data` and `config.yaml`, losing the encryption key makes the data unreadable
