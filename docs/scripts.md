# Scripts

## Layout

```
install.sh        runs servers/<name>/install.sh
scripts/lib/
  common.sh       logging, root check, secrets, server.env loading
  templates.sh    .example templates and stack .env building
  swap.sh         swap file setup
  packages.sh     apt package upgrades
  docker.sh       Docker install, networks, compose up, image prune
  gpu.sh          NVIDIA Container Toolkit setup
  netbird.sh      Netbird client install
  stacks.sh       copying stacks and deploying them
  schedule.sh     systemd update timer
  server.sh       install_server and update_server
servers/<name>/
  server.env
  server.local.env.example
  install.sh
  update.sh
  stacks/<stack>/
```

## install.sh

Run once on a new server:

```
git clone <repo-url> ~/labnet
sudo bash ~/labnet/install.sh <name>
```

The root `install.sh` runs `servers/<name>/install.sh`, which can also be run directly. The repository can live in any folder, but the update timer points to it, so run `install.sh` again after moving it.

Steps:

1. Creates `/swapfile` when `SWAP_SIZE_MB` is set and no swap is active
2. Upgrades system packages when `UPDATE_PACKAGES=true`
3. Installs Docker if missing (get.docker.com, falls back to apt) and writes `/etc/docker/daemon.json` with log limits when `DOCKER_LOG_MAX_SIZE` is set and the file is missing
4. Installs the NVIDIA Container Toolkit when `GPU_VENDOR=nvidia`
5. Installs the Netbird client when `INSTALL_NETBIRD_CLIENT=true` and it is missing
6. Creates the networks in `DOCKER_NETWORKS`
7. Deploys every stack in `STACKS`
8. Installs the systemd timer `labnet-update-<name>`

The Netbird client is only installed, joining the network is done by hand with `netbird up`.

## update.sh

Runs from the timer, or by hand:

```
sudo bash ~/labnet/servers/<name>/update.sh
```

Steps:

1. `git pull --ff-only` on the repo as the user who owns it (continues with current files if it fails)
2. Upgrades system packages when `UPDATE_PACKAGES=true`, warns if a reboot is required
3. Creates any missing networks
4. Deploys every stack in `STACKS`, pulling new images
5. Removes unused images

Updates never reboot the server.

## Deploying a stack

For each stack in `STACKS`, in order:

1. Copy every file in `servers/<name>/stacks/<stack>` to `STACKS_DIR/<stack>`, except `*.example` files and `hooks/`
2. Create files from `*.example` templates when the target file does not exist
3. Build `.env` from `server.env` and `.env.example`, keeping values that already exist
4. `docker compose pull` and `docker compose up -d --remove-orphans`
5. Run `hooks/after-deploy.sh <target dir>` when it exists

Files edited by hand in `STACKS_DIR` are overwritten on the next update, except files created from templates, `.env` values and data folders.

## server.env

| Key                   | Servers      | Description                                          |
|-----------------------|--------------|------------------------------------------------------|
| SERVER_NAME           | all          | Name used for the update timer                       |
| STACKS_DIR            | all          | Where stacks are deployed, also used by Dockge       |
| STACKS                | all          | Stacks to deploy, in order                           |
| DOCKER_NETWORKS       | all          | External Docker networks to create                   |
| UPDATE_SCHEDULE       | all          | systemd `OnCalendar` value, empty disables the timer |
| UPDATE_PACKAGES       | all          | `true` to upgrade apt packages                       |
| GPU_VENDOR            | arc, asrc    | `nvidia` to set up GPU containers                    |
| SWAP_SIZE_MB          | oracle       | Size of the swap file in MB, empty skips it          |
| DOCKER_LOG_MAX_SIZE   | oracle, arc, asrc | Max size of one container log file, 3 files are kept |
| INSTALL_NETBIRD_CLIENT | oracle, arc, asrc | `true` to install the Netbird client            |
| NETBIRD_DOMAIN        | oracle, arc, asrc | Public domain for Netbird, `netbird.autonomousrobotics.club` |
| AUTHENTIK_DOMAIN      | oracle       | Public domain for Authentik, `auth.autonomousrobotics.club` |
| ARC_HOST, ASRC_HOST, UGREEN_HOST | oracle | Netbird IP of each server, used by the Glance pages |
| DATABASE_BIND_ADDRESS | asrc         | Address Postgres and Valkey are published on         |

Every key is written to each stack `.env` and can be used in templates as `{{KEY}}`.

## server.local.env

Optional. To override a value on one machine without changing the repository, copy `servers/<name>/server.local.env.example` to `servers/<name>/server.local.env` and edit it. The file is not tracked by git, so `git pull` never touches it. Its values override `server.env`.

The scripts stop when any value still contains `example.com`.

## Update schedule

| Server | Time  | Packages |
|--------|-------|----------|
| oracle | 04:00 | yes      |
| arc    | 04:30 | yes      |
| asrc   | 05:00 | yes      |
| ugreen | 05:30 | no       |

Each run has up to 15 minutes of random delay. Check the timer with:

```
systemctl list-timers 'labnet-update-*'
journalctl -u labnet-update-<name>
```

## Template placeholders

| Placeholder               | Value                       |
|---------------------------|-----------------------------|
| `{{KEY}}`                 | Value of KEY in server.env  |
| `__GENERATE_SECRET__`     | Random 64 character hex     |
| `__GENERATE_BASE64_KEY__` | Random 32 byte base64 key   |

Secrets are generated once and kept in the target file.
