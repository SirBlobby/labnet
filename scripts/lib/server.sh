#!/usr/bin/env bash

LIBRARY_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$LIBRARY_DIR/common.sh"
source "$LIBRARY_DIR/templates.sh"
source "$LIBRARY_DIR/swap.sh"
source "$LIBRARY_DIR/packages.sh"
source "$LIBRARY_DIR/docker.sh"
source "$LIBRARY_DIR/gpu.sh"
source "$LIBRARY_DIR/netbird.sh"
source "$LIBRARY_DIR/stacks.sh"
source "$LIBRARY_DIR/schedule.sh"

install_server() {
    require_root
    load_server_env "$1"
    require_command git
    ensure_swap
    update_system_packages
    ensure_docker
    ensure_gpu_support
    ensure_netbird_client
    ensure_networks
    deploy_all_stacks
    install_update_timer
    log_info "Install finished for $SERVER_NAME"
}

update_server() {
    require_root
    load_server_env "$1"
    update_system_packages
    ensure_networks
    deploy_all_stacks
    prune_unused_images
    log_info "Update finished for $SERVER_NAME"
}
