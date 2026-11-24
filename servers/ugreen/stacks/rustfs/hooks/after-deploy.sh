#!/usr/bin/env bash
set -euo pipefail

container_name="rustfs"
health_status=""

for attempt in $(seq 1 60); do
    health_status="$(docker inspect -f '{{.State.Health.Status}}' "$container_name" 2>/dev/null || true)"
    if [[ "$health_status" == "healthy" ]]; then
        break
    fi
    sleep 2
done

if [[ "$health_status" != "healthy" ]]; then
    printf '[labnet] warning: %s is not healthy, skipping bucket setup\n' "$container_name" >&2
    exit 0
fi

# Creates every bucket in RUSTFS_BUCKETS (comma separated) that does not exist yet.
# Runs inside the container so the keys never appear on the host command line.
docker exec "$container_name" sh -ec '
    IFS=","
    for bucket in $RUSTFS_BUCKETS; do
        bucket="$(echo "$bucket" | tr -d "[:space:]")"
        [ -n "$bucket" ] || continue
        url="http://127.0.0.1:9000/$bucket"
        auth="$RUSTFS_ACCESS_KEY:$RUSTFS_SECRET_KEY"
        if curl -fs -o /dev/null -I --aws-sigv4 "aws:amz:us-east-1:s3" --user "$auth" "$url"; then
            continue
        fi
        curl -fsS -o /dev/null -X PUT --aws-sigv4 "aws:amz:us-east-1:s3" --user "$auth" "$url"
        echo "[labnet] Created bucket $bucket"
    done
'
