# oracle

| Item        | Value                         |
|-------------|-------------------------------|
| Host        | Oracle Cloud Free VPS         |
| OS          | Ubuntu 24.04                  |
| Role        | Public gateway, VPN control   |
| Stacks      | npm, netbird, dockge          |
| STACKS_DIR  | /opt/stacks                   |
| Updates     | 04:00 daily, packages and stacks |

## Ports

| Port | Protocol | Service              | Exposure |
|------|----------|----------------------|----------|
| 22   | tcp      | SSH                  | Public   |
| 80   | tcp      | NPM HTTP             | Public   |
| 443  | tcp      | NPM HTTPS            | Public   |
| 81   | tcp      | NPM admin            | VPN      |
| 3478 | udp      | Netbird STUN         | Public   |
| 8081 | tcp      | Netbird server       | Local    |
| 8082 | tcp      | Netbird dashboard    | Local    |
| 5001 | tcp      | Dockge               | VPN      |

## Setup

1. Point a DNS A record for `NETBIRD_DOMAIN` to the public IP
2. Set `NETBIRD_DOMAIN` in `servers/oracle/server.env`
3. Open 22, 80, 443 and 3478/udp in the Oracle security list
4. Allow the same ports in the host `iptables` rules
5. `sudo bash /opt/labnet/servers/oracle/install.sh`
6. Set up NPM, see [npm](../stacks/npm.md)
7. Set up Netbird, see [netbird](../stacks/netbird.md)
8. Install the Netbird client on oracle so Dockge and NPM admin are reachable over the VPN

## Notes

- Netbird and NPM use their built-in SQLite, so the VPN does not depend on the database on asrc
- Ports 81 and 5001 should only be reached through the VPN, keep them closed in the security list
