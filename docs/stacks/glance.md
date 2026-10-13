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
| /var/run/docker.sock | /var/run/docker.sock | Container list, read only     |

## Config

The dashboard is defined in `config/glance.yml`. Edit it in the repository, it is copied to `/opt/stacks/glance/config` on every update and Glance reloads it without a restart.

| Widget             | Shows                                               |
|--------------------|-----------------------------------------------------|
| clock, calendar    | Time and date in `TZ`                               |
| server-stats       | CPU, memory and disk of oracle                      |
| monitor            | Up or down status of Netbird, Authentik, NPM, Dockge |
| docker-containers  | State of every container on oracle                  |
| bookmarks          | Admin and docs links                                |

To add a service to the monitor:

```yaml
              - title: Example
                url: http://example.robotics.lab
                check-url: http://172.17.0.1:8085
                icon: di:example
```

`url` is where a click goes, `check-url` is what Glance tests from inside its container. Use `check-url` for `robotics.lab` names, Glance cannot resolve them. Icons with `di:` come from the Dashboard Icons set.

See the [Glance docs](https://github.com/glanceapp/glance/blob/main/docs/configuration.md) for all widgets.

## Access

The dashboard is for VPN users only, it lists internal services and containers.

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
