#!/usr/bin/env bash

update_system_packages() {
    if [[ "${UPDATE_PACKAGES:-false}" != "true" ]]; then
        log_info "UPDATE_PACKAGES is not true, skipping system package updates"
        return 0
    fi

    require_command apt-get
    log_info "Updating system packages"

    export DEBIAN_FRONTEND=noninteractive
    apt-get update
    apt-get upgrade -y \
        -o Dpkg::Options::=--force-confdef \
        -o Dpkg::Options::=--force-confold
    apt-get autoremove -y
    apt-get autoclean -y

    if [[ -f /var/run/reboot-required ]]; then
        log_warning "A reboot is required to finish package updates"
    fi
}
