# rustfs

S3 compatible object storage for backups and app files.

| Item        | Value                                  |
|-------------|----------------------------------------|
| Server      | ugreen                                 |
| Image       | `rustfs/rustfs:1.0.6`                  |
| Containers  | rustfs, rustfs-permissions (runs once) |
| Source      | `servers/ugreen/stacks/rustfs`         |
| Data        | `/volume1/docker/stacks/rustfs/data`   |
| Secrets     | `/volume1/docker/stacks/rustfs/.env`   |

## Ports

| Host port                   | Container | Container port | Protocol | Service    |
|-----------------------------|-----------|----------------|----------|------------|
| `RUSTFS_BIND_ADDRESS`:9000  | rustfs    | 9000           | tcp      | S3 API     |
| `RUSTFS_BIND_ADDRESS`:9001  | rustfs    | 9001           | tcp      | Web console |

## Volumes

| Host    | Container | Purpose      |
|---------|-----------|--------------|
| ./data  | /data     | Object data  |

RustFS runs as user `10001`. The `rustfs-permissions` container sets the owner of `./data` before RustFS starts.

## Environment

| Variable          | Default          | Description                                     |
|-------------------|------------------|-------------------------------------------------|
| RUSTFS_ACCESS_KEY | `labnet-admin`   | Admin access key, also the console user name    |
| RUSTFS_SECRET_KEY | generated        | Admin secret key, also the console password     |
| RUSTFS_BUCKETS    | `backups`        | Comma separated buckets created by the setup hook |

`RUSTFS_BIND_ADDRESS` is set in `servers/ugreen/server.env`, see [VPN access](../vpn-access.md).

## Setup

1. Run `install.sh ugreen` or `update.sh` on ugreen
2. The setup hook waits for RustFS to be healthy and creates every bucket in `RUSTFS_BUCKETS` that does not exist yet
3. Get the admin keys: `sudo grep RUSTFS_ /volume1/docker/stacks/rustfs/.env`
4. Open the console at `http://<ugreen ip>:9001` and log in with the access key and secret key
5. Create a separate access key for each app in the console, do not give apps the admin keys

To add a bucket later, add it to `RUSTFS_BUCKETS` in `/volume1/docker/stacks/rustfs/.env` and run `update.sh`, or create it in the console.

## Connecting

| From                 | Endpoint                          |
|----------------------|-----------------------------------|
| Stacks on ugreen     | `http://<ugreen netbird ip>:9000` or `http://<ugreen lan ip>:9000` |
| Other servers, VPN   | `http://100.82.4.126:9000`        |

Use path style addressing and region `us-east-1`. Example with the AWS CLI:

```
aws --endpoint-url http://100.82.4.126:9000 s3 ls
```

## Notes

- Traffic is plain HTTP, it is encrypted by WireGuard when it goes over the VPN. Do not make port 9000 public without TLS
- RustFS checks the disk layout on start. If it refuses to start on the NAS volume, check `docker logs rustfs`
- Back up `./data` or replicate buckets to another target, a single disk has no redundancy beyond the NAS RAID
