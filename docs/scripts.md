# Scripts

## Layout

```
scripts/lib/
  common.sh       logging, root check, secrets, server.env loading
  templates.sh    .example templates and stack .env building
  packages.sh     apt package upgrades
  docker.sh       Docker install, networks, compose up, image prune
  gpu.sh          NVIDIA Container Toolkit setup
  stacks.sh       copying stacks and deploying them
  schedule.sh     systemd update timer
  server.sh       install_server and update_server
servers/<name>/
  server.env
  install.sh
  update.sh
  stacks/<stack>/
```

## install.sh

Run once on a new server:

```
git clone <repo-url> /opt/labnet
sudo bash /opt/labnet/servers/<name>/install.sh
```

Steps:

1. Upgrades system packages when `UPDATE_PACKAGES=true`
2. Installs Docker if missing (get.docker.com, falls back to apt)
3. Installs the NVIDIA Container Toolkit when `GPU_VENDOR=nvidia`
4. Creates the networks in `DOCKER_NETWORKS`
5. Deploys every stack in `STACKS`
6. Installs the systemd timer `labnet-update-<name>`

## update.sh

Runs from the timer, or by hand:

```
sudo bash /opt/labnet/servers/<name>/update.sh
```

Steps:

1. `git pull --ff-only` on the repo (continues with current files if it fails)
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
| NETBIRD_DOMAIN        | oracle       | Public domain for Netbird                            |
| DATABASE_BIND_ADDRESS | asrc         | Address Postgres and Valkey are published on         |

Every key is written to each stack `.env` and can be used in templates as `{{KEY}}`.

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
