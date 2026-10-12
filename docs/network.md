# Network

## Topology

```
                 Internet
                    |
        80, 443, 3478/udp
                    |
     +--------------------------------+
     | oracle (public IP)             |
     |  nginx-proxy-manager           |
     |  netbird-server                |
     |  netbird-dashboard             |
     +--------------------------------+
                    |
            Netbird VPN (WireGuard)
          /         |          \
   +---------+  +---------+  +---------+
   |  arc    |  |  asrc   |  | ugreen  |
   |  GPU    |  |  GPU    |  |  NAS    |
   |         |  | postgres|  |         |
   |         |  | valkey  |  |         |
   +---------+  +---------+  +---------+
   university firewall      home or lab LAN
```

## Traffic flows

| From             | To                          | Path                                                   |
|------------------|-----------------------------|--------------------------------------------------------|
| Internet         | Lab service on arc or asrc  | oracle:443 -> NPM -> Netbird IP of the server:port      |
| Internet         | Netbird dashboard           | oracle:443 -> NPM -> host:8082                          |
| Netbird clients  | Netbird management          | oracle:443 -> NPM -> host:8081 (gRPC)                   |
| Netbird clients  | Relay                       | oracle:443 -> NPM -> host:8081 `/relay`                 |
| Netbird clients  | STUN                        | oracle:3478/udp                                         |
| arc, ugreen      | Postgres or Valkey          | Netbird IP of asrc:5432 or :6379                        |
| asrc stacks      | Postgres or Valkey          | `core-postgres:5432`, `core-valkey:6379` on `core-data` |
| Admin            | Dockge, NPM admin           | Netbird IP of the server:5001 or oracle:81              |

## Exposing a lab service to the internet

1. Make sure the service port is published on arc or asrc
2. In NPM, add a proxy host for the domain
3. Forward to the Netbird IP of the server and the service port
4. Request an SSL certificate in NPM

## Docker networks

| Network     | Server | Created by     | Used by                                 |
|-------------|--------|----------------|-----------------------------------------|
| `core-data` | asrc   | install.sh     | database stack and any stack on asrc that needs the database |
| `<stack>_default` | all | docker compose | Containers inside one stack          |
