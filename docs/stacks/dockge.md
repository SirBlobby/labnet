# dockge

Web UI for managing Docker compose stacks.

| Item        | Value                                  |
|-------------|----------------------------------------|
| Servers     | oracle, arc, asrc, ugreen              |
| Image       | louislam/dockge:latest                 |
| Container   | dockge                                 |
| Source      | `servers/<name>/stacks/dockge`         |
| Data        | `STACKS_DIR/dockge/data`               |

## Ports

| Host port | Container port | Protocol | Service   |
|-----------|----------------|----------|-----------|
| 5001      | 5001           | tcp      | Dockge UI |

## Volumes

| Host                    | Container               | Purpose                |
|-------------------------|-------------------------|------------------------|
| /var/run/docker.sock    | /var/run/docker.sock    | Docker control         |
| ./data                  | /app/data               | Dockge settings, users |
| `STACKS_DIR`            | `STACKS_DIR`            | Managed stacks         |

## Environment

| Variable          | Value        |
|-------------------|--------------|
| DOCKGE_STACKS_DIR | `STACKS_DIR` |

## Setup

1. Open `http://<server>:5001`
2. Create the admin account on first visit

## Notes

- Stacks deployed by `install.sh` show up in Dockge because they share `STACKS_DIR`
- Changes made in Dockge to `compose.yaml` are overwritten by `update.sh`, make changes in the repo instead
- Stacks created only in Dockge are not touched by `update.sh`
