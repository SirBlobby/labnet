# Lab Net Docs

## Overview

| Doc                                | Contents                                        |
|------------------------------------|-------------------------------------------------|
| [Ports](ports.md)                  | Port map for every server and stack             |
| [Network](network.md)              | How traffic flows between servers and the VPN   |
| [Scripts](scripts.md)              | install.sh, update.sh, server.env, templates    |
| [GPU](gpu.md)                      | NVIDIA setup on ARC and ASRC                    |
| [Extending](extending.md)          | Adding servers, stacks and databases            |

## Servers

| Server                          | Host                     | Stacks               |
|---------------------------------|--------------------------|----------------------|
| [oracle](servers/oracle.md)     | Oracle Cloud (Ubuntu 24) | npm, netbird, dockge |
| [arc](servers/arc.md)           | ARC Server (Ubuntu 26)   | dockge               |
| [asrc](servers/asrc.md)         | ASRC (Ubuntu 24)         | database, dockge     |
| [ugreen](servers/ugreen.md)     | UGREEN NAS (UGOS)        | dockge               |

## Stacks

| Stack                              | Servers                  | Purpose                              |
|------------------------------------|--------------------------|--------------------------------------|
| [dockge](stacks/dockge.md)         | all                      | Web UI for managing compose stacks   |
| [netbird](stacks/netbird.md)       | oracle                   | VPN management, signal, relay, STUN  |
| [npm](stacks/npm.md)               | oracle                   | Reverse proxy and SSL certificates   |
| [database](stacks/database.md)     | asrc                     | Central Postgres and Valkey          |
