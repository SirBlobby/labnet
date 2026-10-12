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
2. `git clone <repo-url> ~/labnet`
3. `sudo bash ~/labnet/install.sh asrc`
4. Join the VPN: `sudo netbird up --management-url https://netbird.autonomousrobotics.club --setup-key <key>`
5. To share the database with other servers, set `DATABASE_BIND_ADDRESS` to the asrc Netbird IP in `servers/asrc/server.local.env` and run `sudo bash ~/labnet/servers/asrc/update.sh`

The install script sets up Docker, the NVIDIA Container Toolkit, the Netbird client, all stacks and the update timer.

## Notes

- Database secrets are in `/opt/stacks/database/.env`
- Back up `/opt/stacks/database/data`
- The Netbird client must be connected before the database stack starts when bound to the Netbird IP
