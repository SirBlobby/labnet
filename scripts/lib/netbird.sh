#!/usr/bin/env bash

ensure_netbird_client() {
    local management_url="https://${NETBIRD_DOMAIN:-<netbird domain>}"

    if [[ "${INSTALL_NETBIRD_CLIENT:-false}" != "true" ]]; then
        return 0
    fi

    if command -v netbird >/dev/null 2>&1; then
        return 0
    fi

    log_info "Installing the Netbird client"
    require_command curl
    if ! curl -fsSL https://pkgs.netbird.io/install.sh | sh; then
        log_warning "Netbird client install failed, install it by hand"
        return 0
    fi

    log_info "Join the network with: netbird up --management-url $management_url --setup-key <key>"
}

# Docker can only publish a port on the Netbird IP once wt0 exists. At boot,
# hold Docker back until Netbird is up (at most 90 seconds, then start anyway).
ensure_docker_waits_for_netbird() {
    local dropin_dir="/etc/systemd/system/docker.service.d"
    local dropin_file="$dropin_dir/labnet-netbird.conf"
    local new_file

    if [[ "${WAIT_FOR_NETBIRD:-false}" != "true" ]]; then
        if [[ -f "$dropin_file" ]]; then
            rm -f "$dropin_file"
            systemctl daemon-reload
            log_info "Removed the Docker wait for Netbird"
        fi
        return 0
    fi

    new_file="$(mktemp)"
    cat > "$new_file" <<'UNIT'
[Unit]
Wants=netbird.service
After=netbird.service

[Service]
TimeoutStartSec=180
ExecStartPre=-/usr/bin/timeout 90 /bin/sh -c 'until ip -4 addr show wt0 2>/dev/null | grep -q inet; do sleep 1; done'
UNIT

    if [[ -f "$dropin_file" ]] && cmp -s "$new_file" "$dropin_file"; then
        rm -f "$new_file"
        return 0
    fi

    mkdir -p "$dropin_dir"
    install -m 644 "$new_file" "$dropin_file"
    rm -f "$new_file"
    systemctl daemon-reload
    log_info "Docker now waits for Netbird at boot"
}
