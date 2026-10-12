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
