#!/usr/bin/env bash
set -euo pipefail

container_name="core-postgres"
health_status=""

for attempt in $(seq 1 60); do
    health_status="$(docker inspect -f '{{.State.Health.Status}}' "$container_name" 2>/dev/null || true)"
    if [[ "$health_status" == "healthy" ]]; then
        break
    fi
    sleep 2
done

if [[ "$health_status" != "healthy" ]]; then
    printf '[labnet] error: %s is not healthy, skipping database setup\n' "$container_name" >&2
    exit 1
fi

docker exec "$container_name" bash /docker-entrypoint-initdb.d/10-service-databases.sh
