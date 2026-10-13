# Port Map

Exposure levels:

| Level   | Meaning                                                        |
|---------|----------------------------------------------------------------|
| Public  | Open to the internet in the Oracle security list               |
| VPN     | Reach it through the Netbird network only                      |
| LAN     | Reachable on the university or home network the host is on     |
| Local   | Bound to 127.0.0.1 or only inside a Docker network             |

Docker publishes ports on all interfaces and bypasses `ufw`. Ports that should not be public must be blocked by the Oracle security list or the network firewall.

## oracle

| Host port | Protocol | Container           | Container port | Service                     | Exposure |
|-----------|----------|---------------------|----------------|-----------------------------|----------|
| 22        | tcp      | host                | -              | SSH                         | Public   |
| 80        | tcp      | nginx-proxy-manager | 80             | HTTP, Let's Encrypt         | Public   |
| 443       | tcp      | nginx-proxy-manager | 443            | HTTPS for all proxied sites | Public   |
| 81        | tcp      | nginx-proxy-manager | 81             | NPM admin UI                | VPN      |
| 3478      | udp      | netbird-server      | 3478           | Netbird STUN                | Public   |
| 8081      | tcp      | netbird-server      | 80             | Netbird API, gRPC, relay    | Local    |
| 8082      | tcp      | netbird-dashboard   | 80             | Netbird dashboard           | Local    |
| 8083      | tcp      | authentik-server    | 9000           | Authentik web UI and API    | Local    |
| 8084      | tcp      | glance              | 8080           | Glance dashboard            | Local    |
| 25570     | tcp      | nginx-proxy-manager | 25570          | Minecraft event Java stream to arc | Public |
| 19132     | udp      | nginx-proxy-manager | 19132          | Minecraft play Bedrock stream to arc | Public |
| 25572     | tcp      | nginx-proxy-manager | 25572          | Minecraft play Java stream to arc | Public |
| 19133     | udp      | nginx-proxy-manager | 19133          | Minecraft event Bedrock stream to arc | Public |
| 25585     | tcp      | nginx-proxy-manager | 25585          | Minecraft cobbleverse Java stream to arc | Public |
| 24454     | udp      | nginx-proxy-manager | 24454          | Minecraft cobbleverse voice chat stream to arc | Public |
| 5001      | tcp      | dockge              | 5001           | Dockge UI                   | VPN      |

Ports 8081 to 8084 are published on all interfaces but only used by NPM. Keep them closed in the security list.

## arc

| Host port | Protocol | Container | Container port | Service    | Exposure |
|-----------|----------|-----------|----------------|------------|----------|
| 22        | tcp      | host      | -              | SSH        | LAN, VPN |
| 5001      | tcp      | dockge    | 5001           | Dockge UI  | LAN, VPN |

## asrc

| Host port | Protocol | Container     | Container port | Service    | Exposure                     |
|-----------|----------|---------------|----------------|------------|------------------------------|
| 22        | tcp      | host          | -              | SSH        | LAN, VPN                     |
| 5001      | tcp      | dockge        | 5001           | Dockge UI  | LAN, VPN                     |
| 5432      | tcp      | core-postgres | 5432           | Postgres   | Local, VPN when bound to Netbird IP |
| 6379      | tcp      | core-valkey   | 6379           | Valkey     | Local, VPN when bound to Netbird IP |

Postgres and Valkey bind to `DATABASE_BIND_ADDRESS` (default `127.0.0.1`).

## ugreen

| Host port | Protocol | Container | Container port | Service    | Exposure |
|-----------|----------|-----------|----------------|------------|----------|
| 22        | tcp      | host      | -              | SSH        | LAN, VPN |
| 5001      | tcp      | dockge    | 5001           | Dockge UI  | LAN, VPN |

UGOS uses its own ports for the NAS web UI (9443 and 9999 by default). Check that 5001 is not already used by the NAS before installing.

## Netbird client (every server)

| Port  | Protocol | Service                        | Notes                                  |
|-------|----------|--------------------------------|----------------------------------------|
| 51820 | udp      | WireGuard peer to peer traffic | Outbound only is enough, relay is used when direct connection fails |

## Internal ports (not published)

| Container      | Port | Service                  |
|----------------|------|--------------------------|
| netbird-server | 9090 | Metrics                  |
| netbird-server | 9000 | Health check             |
| authentik-postgres | 5432 | Authentik database   |

## Oracle security list

| Port | Protocol | Source    |
|------|----------|-----------|
| 22   | tcp      | 0.0.0.0/0 |
| 80   | tcp      | 0.0.0.0/0 |
| 443  | tcp      | 0.0.0.0/0 |
| 3478 | udp      | 0.0.0.0/0 |
| 25570 | tcp     | 0.0.0.0/0 |
| 19132 | udp     | 0.0.0.0/0 |
| 25572 | tcp     | 0.0.0.0/0 |
| 19133 | udp     | 0.0.0.0/0 |
| 25585 | tcp     | 0.0.0.0/0 |
| 24454 | udp     | 0.0.0.0/0 |

The Oracle Ubuntu image also has `iptables` rules that block incoming traffic. Allow the same ports there.

## Port reservations

Use these ranges for new stacks to avoid conflicts:

| Range     | Use                         |
|-----------|-----------------------------|
| 3000-3999 | Web apps                    |
| 5001      | Dockge (every server)       |
| 5432      | Postgres (asrc)             |
| 6379      | Valkey (asrc)               |
| 8000-8999 | APIs and services behind NPM |
| 19132     | Minecraft Bedrock, see [Minecraft](minecraft.md) |
| 25565-25599 | Minecraft Java, see [Minecraft](minecraft.md) |
