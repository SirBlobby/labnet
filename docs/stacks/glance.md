# glance

Glance dashboard, the start page for Lab Net with service status and links.

| Item        | Value                                  |
|-------------|----------------------------------------|
| Server      | oracle                                 |
| Image       | glanceapp/glance:latest                |
| Container   | glance                                 |
| Source      | `servers/oracle/stacks/glance`         |
| Config      | `servers/oracle/stacks/glance/config/glance.yml` |
| Memory      | Limited to 96 MB                       |

## Ports

| Host port | Container port | Protocol | Service   | Exposure |
|-----------|----------------|----------|-----------|----------|
| 8084      | 8080           | tcp      | Dashboard | Local    |

## Volumes

| Host                 | Container            | Purpose                       |
|----------------------|----------------------|-------------------------------|
| ./config             | /app/config          | Dashboard config, read only   |

## Config

The dashboard is defined in `config/glance.yml`. Edit it in the repository, it is copied to `/opt/stacks/glance/config` on every update and Glance reloads it without a restart.

## Pages

There is one page for each server, with the services hosted on it.

| Page   | Contents                                                    |
|--------|-------------------------------------------------------------|
| Home   | Clock, calendar, public services, admin and docs links      |
| Oracle | CPU, memory and disk of oracle, Netbird, Authentik, NPM, Dockge |
| ARC    | Dockge                                                      |
| ASRC   | Dockge                                                      |
| UGREEN | Dockge, UGOS web UI                                         |

## Server addresses

The pages for the other servers use the address of each server from `servers/oracle/server.env`.

| Key         | Value                          |
|-------------|--------------------------------|
| ARC_HOST    | Netbird IP of arc              |
| ASRC_HOST   | Netbird IP of asrc             |
| UGREEN_HOST | Netbird IP of ugreen           |

Find the IP under Peers in the Netbird dashboard. Set the values and run `update.sh` on oracle. Services of a server show as down until its address is set.

Use the IP, not a `robotics.lab` or `netbird.selfhosted` name. Glance runs in a container and does not use Netbird DNS.

## Adding a service

Add it to the monitor on the page of the server that hosts it.

On oracle:

```yaml
              - title: Example
                url: http://example.robotics.lab
                check-url: http://172.17.0.1:8085
                icon: di:example
```

On another server:

```yaml
              - title: Example
                url: http://${ARC_HOST}:3000
                icon: di:example
```

`url` is where a click goes, `check-url` is what Glance tests from inside its container. Use `check-url` when `url` is a `robotics.lab` name. Icons with `di:` come from the Dashboard Icons set.

The monitor only checks web pages. Postgres and Valkey on asrc cannot be listed.

When a new server is added, add a `<NAME>_HOST` key and a new page.

See the [Glance docs](https://github.com/glanceapp/glance/blob/main/docs/configuration.md) for all widgets.

## Access

The dashboard is for VPN users only, it lists internal services.

1. In the Netbird dashboard add an A record `glance` in the `robotics.lab` zone that points to the oracle Netbird IP
2. In NPM add a proxy host:

| Field                 | Value                 |
|-----------------------|-----------------------|
| Domain Names          | `glance.robotics.lab` |
| Scheme                | `http`                |
| Forward Hostname / IP | `172.17.0.1`          |
| Forward Port          | `8084`                |
| Access List           | `vpn-only`            |

3. Open `http://glance.robotics.lab` from a device on the VPN

## Notes

- Do not make the dashboard public, there is no login
- Keep port 8084 closed in the security list
- Change `TZ` in `compose.yaml` if the lab moves time zone
