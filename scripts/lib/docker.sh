#!/usr/bin/env bash

install_docker_from_apt() {
    require_command apt-get
    apt-get update
    apt-get install -y docker.io docker-compose-v2
}

configure_docker_log_limits() {
    local daemon_file="/etc/docker/daemon.json"

    if [[ -z "${DOCKER_LOG_MAX_SIZE:-}" ]]; then
        return 0
    fi

    if [[ -f "$daemon_file" ]]; then
        if ! grep -q '"max-size"' "$daemon_file"; then
            log_warning "$daemon_file already exists, add the log limits by hand"
        fi
        return 0
    fi

    mkdir -p "$(dirname "$daemon_file")"
    cat > "$daemon_file" <<EOF
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "$DOCKER_LOG_MAX_SIZE",
    "max-file": "3"
  }
}
EOF

    systemctl restart docker >/dev/null 2>&1 || log_warning "Could not restart the docker service"
    log_info "Container logs limited to 3 files of $DOCKER_LOG_MAX_SIZE"
}

ensure_docker() {
    if ! command -v docker >/dev/null 2>&1; then
        log_info "Installing Docker"
        require_command curl
        if ! curl -fsSL https://get.docker.com | sh; then
            log_warning "Docker install script failed, installing from apt"
            install_docker_from_apt
        fi
    fi

    configure_docker_log_limits
    systemctl enable --now docker >/dev/null 2>&1 || log_warning "Could not enable the docker service"

    if ! docker compose version >/dev/null 2>&1; then
        fail "Docker Compose plugin is not available"
    fi
}

ensure_networks() {
    local network_name

    for network_name in ${DOCKER_NETWORKS:-}; do
        if ! docker network inspect "$network_name" >/dev/null 2>&1; then
            docker network create "$network_name" >/dev/null
            log_info "Created network $network_name"
        fi
    done
}

start_stack() {
    local compose_file="$1/compose.yaml"

    docker compose -f "$compose_file" pull
    docker compose -f "$compose_file" up -d --remove-orphans
}

prune_unused_images() {
    docker image prune -f >/dev/null
}
