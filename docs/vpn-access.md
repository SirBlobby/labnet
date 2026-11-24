# VPN access

How to reach services on a lab server through the Netbird VPN, and how to make them reachable only through the VPN.

## Bind addresses

Each stack publishes its ports on an address set in `server.env`:

| Key                    | Server | Stack    | Ports       |
|------------------------|--------|----------|-------------|
| DATABASE_BIND_ADDRESS  | ugreen | database | 5432, 6379  |
| RUSTFS_BIND_ADDRESS    | ugreen | rustfs   | 9000, 9001  |
| IMMICH_BIND_ADDRESS    | ugreen | immich   | 2283        |

| Value                      | Reachable from                         |
|----------------------------|----------------------------------------|
| `127.0.0.1`                | The server itself only                 |
| Netbird IP, `100.82.4.126` | VPN only                               |
| `0.0.0.0`                  | VPN and the LAN the server is on       |

Current defaults on ugreen:

| Stack    | Default          | Why                                                      |
|----------|------------------|----------------------------------------------------------|
| database | `100.82.4.126`   | Postgres and Valkey are shared with the other servers, never with the LAN |
| rustfs   | `0.0.0.0`        | LAN clients can back up without the VPN                  |
| immich   | `0.0.0.0`        | Phones on home Wi-Fi upload at LAN speed                 |

## Making a service VPN only

1. On ugreen, copy the local settings file:
   ```
   cp /volume1/docker/labnet/servers/ugreen/server.local.env.example /volume1/docker/labnet/servers/ugreen/server.local.env
   ```
2. Set the bind address of the service to the Netbird IP, for example `RUSTFS_BIND_ADDRESS=100.82.4.126`
3. Run `sudo bash /volume1/docker/labnet/servers/ugreen/update.sh`
4. Check: `sudo ss -ltnp | grep -E ':(2283|5432|6379|9000|9001) '` shows the Netbird IP, not `0.0.0.0`

`server.local.env` is not tracked by git, so the change stays on that machine. To change the default for everyone, edit `servers/ugreen/server.env` instead.

## Boot order

Docker can only publish a port on the Netbird IP after the `wt0` interface exists. With `WAIT_FOR_NETBIRD=true` in `server.env`, `install.sh` and `update.sh` add a systemd drop-in that makes Docker wait for Netbird at boot:

| Item    | Value                                                  |
|---------|--------------------------------------------------------|
| File    | `/etc/systemd/system/docker.service.d/labnet-netbird.conf` |
| Waits   | Up to 90 seconds for `wt0` to have an IPv4 address     |
| Timeout | Docker starts anyway after 90 seconds, so stacks on `0.0.0.0` still come up |

If Netbird was down at boot, containers bound to the Netbird IP fail to start. Once Netbird is connected, start them with `update.sh` or in Dockge.

Check it after a reboot:

```
systemctl cat docker | grep -A3 labnet
journalctl -b -u docker | head
```

## Netbird IP changes

The Netbird IP stays the same unless the peer is deleted and joins again. If it changes:

1. Find the new IP with `sudo netbird status`
2. Update `DATABASE_BIND_ADDRESS` and any other bind addresses in `servers/ugreen/server.env`
3. Update `UGREEN_HOST` in `servers/oracle/server.env` for the dashboard
4. Update the IP in the docs and in apps that connect to it, then run `update.sh` on ugreen and oracle

## Access control

By default the Netbird `All` policy lets every peer reach every other peer. To limit who can reach the NAS:

1. In the Netbird dashboard open Peers, and put ugreen in a group like `storage`
2. Put trusted users and servers in a group like `lab-admins`
3. Open Access Control, Policies, and add a policy from `lab-admins` to `storage` on TCP ports `2283, 5001, 5432, 6379, 9000, 9001`
4. Allow oracle to reach `storage` on the same ports, Glance checks the services from there
5. Turn off or narrow the default `All` policy

## Names instead of IPs

Add A records in the Netbird DNS zone `robotics.lab` (Netbird dashboard, DNS, Zones):

| Name                    | Points to      |
|-------------------------|----------------|
| `photos.robotics.lab`   | `100.82.4.126` |
| `s3.robotics.lab`       | `100.82.4.126` |
| `db.robotics.lab`       | `100.82.4.126` |

Then use `http://photos.robotics.lab:2283` from any device on the VPN. Containers do not use Netbird DNS, so stack configs should keep using the IP.
