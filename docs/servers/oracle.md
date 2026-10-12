# oracle

| Item        | Value                         |
|-------------|-------------------------------|
| Host        | Oracle Cloud Free VPS         |
| OS          | Ubuntu 26.04                  |
| CPU         | 2 cores, AMD EPYC             |
| Memory      | 951 MiB, about 350 MiB used by the OS, 2 GB swap file |
| Storage     | 50 GB (47 GiB usable)         |
| Role        | Public gateway, VPN control   |
| Stacks      | npm, authentik, netbird, dockge |
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
| 8083 | tcp      | Authentik            | Local    |
| 5001 | tcp      | Dockge               | VPN      |

## Domains

| Domain                            | Service   | Setting            |
|-----------------------------------|-----------|--------------------|
| `netbird.autonomousrobotics.club` | Netbird   | `NETBIRD_DOMAIN`   |
| `auth.autonomousrobotics.club`    | Authentik | `AUTHENTIK_DOMAIN` |

New public services use `<subdomain>.autonomousrobotics.club`.

## Setup

1. Point DNS A records for `netbird.autonomousrobotics.club` and `auth.autonomousrobotics.club` to the public IP
2. Open 22, 80, 443 and 3478/udp in the Oracle security list
3. Allow the same ports in the host `iptables` rules
4. `git clone <repo-url> ~/labnet`
5. `sudo bash ~/labnet/install.sh oracle`
6. Set up NPM, see [npm](../stacks/npm.md)
7. Set up Authentik, see [authentik](../stacks/authentik.md)
8. Set up Netbird, see [netbird](../stacks/netbird.md)
9. Join oracle to the VPN so Dockge and NPM admin are reachable: `netbird up --management-url https://netbird.autonomousrobotics.club --setup-key <key>`

The install script sets up the swap file, Docker, all stacks, the Netbird client and the update timer. The other steps are done by hand.

## Storage

| Use                 | Size             | Kept small by                                   |
|---------------------|------------------|-------------------------------------------------|
| Swap file           | 2 GB             | `SWAP_SIZE_MB`                                  |
| Docker images       | A few GB         | Unused images are removed on every update       |
| Container logs      | 30 MB a container | `DOCKER_LOG_MAX_SIZE`, 3 files are kept        |
| Stack data          | Grows slowly     | `/opt/stacks`, mostly the Authentik database    |

Check usage with `df -h /` and `docker system df`.

## Notes

- Ubuntu 26.04 may not be supported by get.docker.com yet, the script falls back to the apt `docker.io` package
- Only about 600 MiB of memory is free for Docker and all stacks, keep new stacks small and set a `mem_limit` on anything heavy, see [authentik](../stacks/authentik.md)
- Netbird and NPM use their built-in SQLite and Authentik has its own Postgres, so the VPN and logins do not depend on the database on asrc
- Ports 81 and 5001 should only be reached through the VPN, keep them closed in the security list
