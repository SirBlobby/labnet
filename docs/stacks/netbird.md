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

Create a proxy host for `NETBIRD_DOMAIN` with SSL, HTTP/2 and websockets enabled.

| Location                          | Forward to          | Scheme |
|-----------------------------------|---------------------|--------|
| `/`                               | 127.0.0.1:8082      | http   |
| `/api`                            | 127.0.0.1:8081      | http   |
| `/oauth2`                         | 127.0.0.1:8081      | http   |
| `/relay`                          | 127.0.0.1:8081      | http   |
| `/ws-proxy/`                      | 127.0.0.1:8081      | http   |
| `/signalexchange.SignalExchange/` | 127.0.0.1:8081      | grpc   |
| `/management.ManagementService/`  | 127.0.0.1:8081      | grpc   |

NPM runs in a container, so `127.0.0.1` points to NPM itself. Use the Docker host gateway (`172.17.0.1`) or the oracle private IP instead.

## Setup

1. Set `NETBIRD_DOMAIN` in `servers/oracle/server.env` before the first install
2. Run `install.sh`
3. Review `config.yaml` and `dashboard.env` against the Netbird self hosting docs
4. Restart the stack in Dockge
5. Add the NPM proxy host
6. Open `https://<NETBIRD_DOMAIN>` and create the admin account

## Notes

- Changing `NETBIRD_DOMAIN` after the first install does not update `config.yaml` or `dashboard.env`, edit them by hand
- Back up `/opt/stacks/netbird/data` and `config.yaml`, losing the encryption key makes the data unreadable
