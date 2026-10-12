# arc

| Item        | Value                         |
|-------------|-------------------------------|
| Host        | ARC Server                    |
| OS          | Ubuntu 26.04                  |
| Role        | GPU compute                   |
| GPU         | NVIDIA                        |
| Stacks      | dockge                        |
| STACKS_DIR  | /opt/stacks                   |
| Updates     | 04:30 daily, packages and stacks |

## Ports

| Port | Protocol | Service | Exposure |
|------|----------|---------|----------|
| 22   | tcp      | SSH     | LAN, VPN |
| 5001 | tcp      | Dockge  | LAN, VPN |

## Setup

1. Install the NVIDIA driver and reboot, see [GPU](../gpu.md)
2. Install the Netbird client and join the network
3. `sudo bash /opt/labnet/servers/arc/install.sh`

## Notes

- Ubuntu 26.04 may not be supported by get.docker.com yet, the script falls back to the apt `docker.io` package
- Services that need the central database connect to the asrc Netbird IP, see [database](../stacks/database.md)
