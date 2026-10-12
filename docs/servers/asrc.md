# asrc

| Item        | Value                         |
|-------------|-------------------------------|
| Host        | ASRC                          |
| OS          | Ubuntu 24.04                  |
| Role        | GPU compute, central database |
| GPU         | NVIDIA                        |
| Stacks      | database, dockge              |
| STACKS_DIR  | /opt/stacks                   |
| Networks    | core-data                     |
| Updates     | 05:00 daily, packages and stacks |

## Ports

| Port | Protocol | Service  | Exposure                            |
|------|----------|----------|-------------------------------------|
| 22   | tcp      | SSH      | LAN, VPN                            |
| 5001 | tcp      | Dockge   | LAN, VPN                            |
| 5432 | tcp      | Postgres | Local, VPN when bound to Netbird IP |
| 6379 | tcp      | Valkey   | Local, VPN when bound to Netbird IP |

## Setup

1. Install the NVIDIA driver and reboot, see [GPU](../gpu.md)
2. Install the Netbird client and join the network
3. Set `DATABASE_BIND_ADDRESS` in `servers/asrc/server.env` to the asrc Netbird IP to share the database with other servers
4. `sudo bash /opt/labnet/servers/asrc/install.sh`

## Notes

- Database secrets are in `/opt/stacks/database/.env`
- Back up `/opt/stacks/database/data`
- The Netbird client must be connected before the database stack starts when bound to the Netbird IP
