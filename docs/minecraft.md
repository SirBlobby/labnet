# Minecraft

How to run a Minecraft server on a lab server and make it public through oracle.

## How it works

```
Player
  |
  |  mc.autonomousrobotics.club:25565
  v
oracle public IP           Oracle security list allows the port
  |
  |  NPM stream            raw TCP or UDP forward, no HTTP
  v
Netbird VPN
  |
  v
lab server Netbird IP:25565
  |
  v
Minecraft container
```

The lab server never needs a public IP or an open port in the university firewall. Players only ever connect to oracle.

## Ports

| Edition | Protocol | Default port |
|---------|----------|--------------|
| Java    | tcp      | 25565        |
| Bedrock | udp      | 19132        |

Use 25565 to 25599 for extra Java servers, see [Ports](ports.md).

Lab Net does not use the default ports on the public side:

| Edition          | Protocol | Public port on oracle | Forwards to           |
|------------------|----------|-----------------------|-----------------------|
| Java             | tcp      | 25570                 | arc Netbird IP:25565  |
| Bedrock (Geyser) | udp      | 19132                 | arc Netbird IP:19132  |

The steps below use the default ports as an example, replace them with the ports above.

## Requirements

- The lab server is a peer on Netbird and shows as connected in the dashboard
- oracle is a peer on Netbird
- The Netbird access policy allows oracle to reach the lab server on the Minecraft port (the default policy allows everything)

## 1. Run the server on the lab server

Add a stack on the lab server, for example `servers/<name>/stacks/minecraft/compose.yaml`:

```yaml
services:
  minecraft:
    image: itzg/minecraft-server:latest
    container_name: minecraft
    restart: unless-stopped
    ports:
      - 25565:25565
    environment:
      EULA: "TRUE"
      MEMORY: 4G
      ENABLE_WHITELIST: "TRUE"
    volumes:
      - ./data:/data
```

Add `minecraft` to `STACKS` in `server.env` and run `update.sh`, see [Extending](extending.md).

Check it from oracle:

```
nc -zv <lab server netbird ip> 25565
```

## 2. Publish the port on NPM

NPM only listens on the ports in its compose file. Add the Minecraft port to `servers/oracle/stacks/npm/compose.yaml`:

```yaml
    ports:
      - 80:80
      - 443:443
      - 81:81
      - 25565:25565
```

For Bedrock add `19132:19132/udp`.

Run `update.sh` on oracle to recreate the container.

## 3. Add the stream in NPM

In the NPM admin UI open Hosts, Streams, Add Stream.

| Field             | Value                       |
|-------------------|-----------------------------|
| Incoming Port     | 25565                       |
| Forward Host      | `<lab server netbird ip>`   |
| Forward Port      | 25565                       |
| TCP Forwarding    | on for Java                 |
| UDP Forwarding    | on for Bedrock              |

Use the Netbird IP, not a `robotics.lab` name. NPM runs in a container and does not use Netbird DNS.

## 4. Open the port in Oracle

Add an ingress rule to the security list, see [oracle](servers/oracle.md).

| Source      | Protocol | Destination port |
|-------------|----------|------------------|
| `0.0.0.0/0` | TCP      | 25565            |
| `0.0.0.0/0` | UDP      | 19132 (Bedrock)  |

## 5. Add the DNS record

In Cloudflare add an A record:

| Type | Name | Content            | Proxy status |
|------|------|--------------------|--------------|
| A    | `mc` | oracle public IP   | DNS only     |

The record must be DNS only. The Cloudflare proxy only carries web traffic and breaks Minecraft.

Players connect to `mc.autonomousrobotics.club`.

## 6. Test

From a computer that is not on the VPN:

```
nc -zv mc.autonomousrobotics.club 25565
```

Then add the server in the Minecraft client.

## Bedrock players with Geyser

Geyser lets Bedrock players join a Java server. It listens on its own UDP port next to the Java port.

1. Install Geyser and Floodgate on the Minecraft server
2. In the Geyser `config.yml` set the Bedrock port to the public port:

```yaml
bedrock:
  address: 0.0.0.0
  port: 19132
```

3. Restart the Minecraft server
4. Publish `19132:19132/udp` in the NPM compose file
5. Add a stream in NPM with incoming port 19132, forward port 19132 and UDP Forwarding on
6. Add a UDP ingress rule for 19132 to the Oracle security list

Keep the Geyser port and the public port the same. Geyser tells Bedrock clients which port it runs on, and a different public port breaks some clients.

Bedrock players connect to `mc.autonomousrobotics.club` with port `19132`. Bedrock has no SRV records, the port must be typed.

## More than one server

Each server needs its own public port on oracle.

| Server   | Public port | Forward to                      |
|----------|-------------|---------------------------------|
| survival | 25565       | `<lab server netbird ip>:25565` |
| creative | 25566       | `<lab server netbird ip>:25566` |

For every extra server:

1. Publish the port in the NPM compose file
2. Add a stream in NPM
3. Add the port to the Oracle security list
4. Add an A record for the name

Players would have to type `creative.autonomousrobotics.club:25566`. To hide the port, add an SRV record in Cloudflare:

| Type | Name                        | Priority | Weight | Port  | Target                            |
|------|-----------------------------|----------|--------|-------|-----------------------------------|
| SRV  | `_minecraft._tcp.creative`  | 0        | 5      | 25566 | `creative.autonomousrobotics.club` |

SRV records only work for Java edition.

## Notes

- The Minecraft server sees every player as coming from the oracle Netbird IP. IP bans and per IP limits do not work, use the whitelist and name bans
- Keep `online-mode` on, the server is reachable by the whole internet
- All game traffic goes through oracle. Check the link between oracle and the lab server with `netbird status -d` on oracle, `P2P` is faster than `Relayed`
- A stream uses very little memory on oracle, the game itself runs on the lab server
- Add every public port to the tables in [Ports](ports.md)

## Troubleshooting

| Problem                                  | Check                                                              |
|------------------------------------------|--------------------------------------------------------------------|
| `nc` from oracle to the lab server fails | Lab server is connected in Netbird, the container is up, the access policy allows the port |
| Works from oracle, times out from outside | Oracle security list rule, port published in the NPM compose file |
| Connection refused from outside          | Stream is missing or disabled in NPM                               |
| Name does not resolve or connects to the wrong place | The DNS record is proxied, set it to DNS only          |
| Players lag or time out                  | Connection between oracle and the lab server is `Relayed`          |
