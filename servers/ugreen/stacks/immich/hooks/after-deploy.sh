#!/usr/bin/env bash
set -euo pipefail

container_name="immich-server"
health_status=""

# The first start runs database migrations, so give it up to 5 minutes.
for attempt in $(seq 1 100); do
    health_status="$(docker inspect -f '{{.State.Health.Status}}' "$container_name" 2>/dev/null || true)"
    if [[ "$health_status" == "healthy" ]]; then
        break
    fi
    sleep 3
done

if [[ "$health_status" != "healthy" ]]; then
    printf '[labnet] warning: %s is not healthy yet, check: docker logs %s\n' "$container_name" "$container_name" >&2
    exit 0
fi

admin_status="$(docker exec "$container_name" node -e \
    "fetch('http://127.0.0.1:2283/api/server/config').then(r => r.text()).then(console.log)" 2>/dev/null || true)"
if [[ "$admin_status" == *'"isInitialized":false'* ]]; then
    printf '[labnet] Immich is running, open http://<ugreen ip>:2283 and create the admin account\n'
else
    printf '[labnet] Immich is running\n'
fi
