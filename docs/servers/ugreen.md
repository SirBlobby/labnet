# ugreen

| Item        | Value                         |
|-------------|-------------------------------|
| Host        | UGREEN DXP NAS (`DXP-ASRC`)   |
| OS          | UGOS Pro (Debian 12)          |
| Role        | Storage, central database, photos, object storage |
| Stacks      | database, rustfs, immich, dockge |
| STACKS_DIR  | /volume1/docker/stacks        |
| Repository  | /volume1/docker/labnet        |
| LAN IP      | 192.168.1.244                 |
| Netbird IP  | 100.82.4.126                  |
| Networks    | core-data                     |
| Updates     | 05:30 daily, stacks only      |

## Ports

| Port | Protocol | Service           | Bind address            | Exposure  |
|------|----------|-------------------|-------------------------|-----------|
| 22   | tcp      | SSH               | host                    | LAN, VPN  |
| 2283 | tcp      | Immich            | `IMMICH_BIND_ADDRESS`   | LAN, VPN  |
| 5001 | tcp      | Dockge            | all                     | LAN, VPN  |
| 5432 | tcp      | Postgres          | `DATABASE_BIND_ADDRESS` | VPN       |
| 6379 | tcp      | Valkey            | `DATABASE_BIND_ADDRESS` | VPN       |
| 9000 | tcp      | RustFS S3 API     | `RUSTFS_BIND_ADDRESS`   | LAN, VPN  |
| 9001 | tcp      | RustFS console    | `RUSTFS_BIND_ADDRESS`   | LAN, VPN  |
| 9443 | tcp      | UGOS web UI       | host                    | LAN       |
| 9999 | tcp      | UGOS web UI       | host                    | LAN       |

See [VPN access](../vpn-access.md) to change what is reachable from the LAN.

## Setup

### 1. Prepare UGOS

1. In the UGOS web UI, Control Panel, Terminal, enable SSH
2. In the App Center, install Docker
3. Log in: `ssh <admin user>@<nas lan ip>`. UGOS users have no home folder, the `Could not chdir to home directory` message is normal
4. Check the basics:
   ```
   docker compose version
   systemctl --version | head -1
   sudo ss -ltnp | grep -E ':(2283|5001|5432|6379|9000|9001) '
   ls -d /volume*
   ```
   The `ss` line must print nothing. If the pool is not `/volume1`, change `STACKS_DIR` in `server.local.env`

### 2. Install git

UGOS ships with some packages (`ctdb`, `picom`) that are missing dependencies, so apt refuses to install anything until that is fixed. Preview the fix first:

```
sudo apt-get -s --fix-broken install | grep -E '^(Inst|Remv)'
```

If there are only `Inst` lines, apply it and install git:

```
sudo apt-get --fix-broken install -y
sudo apt-get install -y git
```

Stop if the preview shows `Remv` lines for UGOS packages. Never run `apt upgrade`, UGOS updates its own packages.

### 3. Join the VPN

Create a setup key in the Netbird dashboard (Setup Keys), then:

```
curl -fsSL https://pkgs.netbird.io/install.sh | sudo sh
sudo netbird up --management-url https://netbird.autonomousrobotics.club --setup-key <key>
sudo netbird status
```

The `Init already exists` error during the install is harmless. `netbird status` needs `sudo` because the connection was made as root. Revoke the setup key if it was reusable.

If the Netbird IP is not `100.82.4.126`, update it in `servers/ugreen/server.env` and `servers/oracle/server.env`, see [VPN access](../vpn-access.md#netbird-ip-changes).

### 4. Install

```
cd /volume1/docker
git clone https://github.com/SirBlobby/labnet.git
sudo bash /volume1/docker/labnet/install.sh ugreen
```

The install:

1. Makes Docker wait for Netbird at boot (`WAIT_FOR_NETBIRD=true`)
2. Creates the `core-data` network
3. Deploys `database`, then creates the service databases
4. Deploys `rustfs`, then creates the buckets in `RUSTFS_BUCKETS`
5. Deploys `immich` and waits for it to be healthy, the first start takes a few minutes
6. Deploys `dockge`
7. Installs the `labnet-update-ugreen` timer

### 5. First logins

Do these right away, the first visitor becomes the admin:

| Service | URL                          | Login                                    |
|---------|------------------------------|------------------------------------------|
| Dockge  | `http://192.168.1.244:5001`  | Create the admin account                 |
| Immich  | `http://192.168.1.244:2283`  | Create the admin account, see [immich](../stacks/immich.md) |
| RustFS  | `http://192.168.1.244:9001`  | Keys from `sudo grep RUSTFS_ /volume1/docker/stacks/rustfs/.env` |

### 6. Check

```
docker ps --format 'table {{.Names}}\t{{.Status}}'
systemctl list-timers 'labnet-update-*'
sudo bash /volume1/docker/labnet/servers/ugreen/update.sh
```

## Secrets

| File                                       | Contents                         |
|--------------------------------------------|----------------------------------|
| `/volume1/docker/stacks/database/.env`     | Postgres, Valkey and service database passwords |
| `/volume1/docker/stacks/rustfs/.env`       | RustFS admin keys                |
| `/volume1/docker/stacks/immich/.env`       | Immich database password         |

## Backups

| Path                                    | What                     |
|-----------------------------------------|--------------------------|
| `/volume1/docker/stacks/database/data`  | Central Postgres, Valkey |
| `/volume1/docker/stacks/immich/data`    | Photos and Immich database |
| `/volume1/docker/stacks/rustfs/data`    | Object storage           |
| The `.env` files above                  | Secrets                  |

Use UGOS snapshots or the UGOS backup app for these folders. For consistent database backups, see [database](../stacks/database.md#backups) and [immich](../stacks/immich.md#backups).

## Notes

- `UPDATE_PACKAGES=false`, system updates are done through UGOS
- Docker comes from the App Center, the script does not install it
- The SSH user on the NAS is named `asrc`, this is not the asrc server. Always run `install.sh ugreen`
- A UGOS firmware update may reset files in `/etc/systemd/system`. If the update timer or the Docker drop-in is gone, run `install.sh ugreen` again
- The repository is cloned as the SSH user, the nightly `git pull` runs as that user
