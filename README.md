# Lab Net

Server configurations and Docker stacks for the lab VPN network. An Oracle Cloud VPS runs Netbird and Nginx Proxy Manager, so lab servers behind the university firewall can join a private VPN and serve traffic on a public IP.

## Servers

| Server | Host                     | Stacks               |
|--------|--------------------------|----------------------|
| oracle | Oracle Cloud (Ubuntu 24) | npm, netbird, dockge |
| arc    | ARC Server (Ubuntu 26), NVIDIA GPU | dockge     |
| asrc   | ASRC (Ubuntu 24), NVIDIA GPU | database, dockge |
| ugreen | UGREEN NAS (UGOS)        | dockge               |

## Quick start

```
git clone <repo-url> /opt/labnet
sudo bash /opt/labnet/servers/<name>/install.sh
```

Updates run nightly from a systemd timer, or by hand:

```
sudo bash /opt/labnet/servers/<name>/update.sh
```

## Layout

```
docs/                   documentation and port maps
scripts/lib/            shared install and update logic
servers/<name>/
  server.env            server settings
  install.sh            first time setup
  update.sh             update packages and redeploy stacks
  stacks/<stack>/       compose.yaml, templates and hooks
```

## Docs

- [Docs index](docs/README.md)
- [Port map](docs/ports.md)
- [Network](docs/network.md)
- [Scripts](docs/scripts.md)
- [GPU](docs/gpu.md)
- [Extending](docs/extending.md)
