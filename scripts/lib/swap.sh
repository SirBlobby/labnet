#!/usr/bin/env bash

ensure_swap() {
    local swap_file="/swapfile"

    if [[ -z "${SWAP_SIZE_MB:-}" ]]; then
        return 0
    fi

    if [[ -n "$(swapon --show --noheadings)" ]]; then
        return 0
    fi

    if [[ ! -f "$swap_file" ]]; then
        log_info "Creating ${SWAP_SIZE_MB}MB swap file"
        dd if=/dev/zero of="$swap_file" bs=1M count="$SWAP_SIZE_MB" status=none
        chmod 600 "$swap_file"
        mkswap "$swap_file" >/dev/null
    fi

    swapon "$swap_file"

    if ! grep -q "^$swap_file " /etc/fstab; then
        printf '%s none swap sw 0 0\n' "$swap_file" >> /etc/fstab
    fi

    log_info "Swap enabled on $swap_file"
}
