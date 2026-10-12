# ugreen

| Item        | Value                         |
|-------------|-------------------------------|
| Host        | UGREEN NAS                    |
| OS          | UGOS                          |
| Role        | Storage                       |
| Stacks      | dockge                        |
| STACKS_DIR  | /volume1/docker/stacks        |
| Updates     | 05:30 daily, stacks only      |

## Ports

| Port | Protocol | Service        | Exposure |
|------|----------|----------------|----------|
| 22   | tcp      | SSH            | LAN, VPN |
| 5001 | tcp      | Dockge         | LAN, VPN |
| 9443 | tcp      | UGOS web UI    | LAN      |
| 9999 | tcp      | UGOS web UI    | LAN      |

## Setup

1. Enable SSH in the UGOS control panel
2. Install Docker from the App Center
3. Make sure `git` is installed
4. Install the Netbird client and join the network: `sudo netbird up --management-url https://netbird.autonomousrobotics.club --setup-key <key>`
5. `git clone <repo-url> /volume1/docker/labnet`
6. `sudo bash /volume1/docker/labnet/install.sh ugreen`

## Notes

- `UPDATE_PACKAGES=false`, system updates are done through UGOS
- Docker and the Netbird client are not installed by the script on UGOS
- Check that port 5001 is free before installing Dockge
- `/volume1` may be named differently depending on the storage pool
