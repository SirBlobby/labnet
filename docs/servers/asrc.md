# asrc

| Item        | Value                         |
|-------------|-------------------------------|
| Host        | ASRC                          |
| OS          | Ubuntu 24.04                  |
| Role        | GPU compute                   |
| GPU         | NVIDIA                        |
| Stacks      | dockge                        |
| STACKS_DIR  | /opt/stacks                   |
| Updates     | 05:00 daily, packages and stacks |

## Ports

| Port | Protocol | Service  | Exposure                            |
|------|----------|----------|-------------------------------------|
| 22   | tcp      | SSH      | LAN, VPN                            |
| 5001 | tcp      | Dockge   | LAN, VPN                            |

## Setup

1. Install the NVIDIA driver and reboot, see [GPU](../gpu.md)
2. `git clone <repo-url> ~/labnet`
3. `sudo bash ~/labnet/install.sh asrc`
4. Join the VPN: `sudo netbird up --management-url https://netbird.autonomousrobotics.club --setup-key <key>`

The install script sets up Docker, the NVIDIA Container Toolkit, the Netbird client, all stacks and the update timer.

## Notes

- The central database moved to ugreen, connect to it over the VPN, see [database](../stacks/database.md)
