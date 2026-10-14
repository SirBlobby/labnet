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
| Netbird IP  | 100.82.10.108                 |
| Dockge      | `http://d1.robotics.lab`      |

## Ports

| Port | Protocol | Service | Exposure |
|------|----------|---------|----------|
| 22   | tcp      | SSH     | LAN, VPN |
| 5001 | tcp      | Dockge  | LAN, VPN |

## Setup

1. Install the NVIDIA driver and reboot, see [GPU](../gpu.md)
2. `git clone <repo-url> ~/labnet`
3. `sudo bash ~/labnet/install.sh arc`
4. Join the VPN: `sudo netbird up --management-url https://netbird.autonomousrobotics.club --setup-key <key>`
5. In the Netbird dashboard add an A record `d1` in the `robotics.lab` zone that points to the oracle Netbird IP
6. In NPM add a proxy host `d1.robotics.lab` to `100.82.10.108:5001` with websockets on and access list `vpn-only`

The install script sets up Docker, the NVIDIA Container Toolkit, the Netbird client, all stacks and the update timer.

## Notes

- Ubuntu 26.04 may not be supported by get.docker.com yet, the script falls back to the apt `docker.io` package
- Services that need the central database connect to the asrc Netbird IP, see [database](../stacks/database.md)
