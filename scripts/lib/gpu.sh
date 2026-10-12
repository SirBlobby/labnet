#!/usr/bin/env bash

NVIDIA_KEYRING_FILE="/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg"
NVIDIA_SOURCES_FILE="/etc/apt/sources.list.d/nvidia-container-toolkit.list"

install_nvidia_container_toolkit() {
    log_info "Installing NVIDIA Container Toolkit"
    require_command apt-get
    require_command curl
    require_command gpg

    curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey \
        | gpg --dearmor --yes -o "$NVIDIA_KEYRING_FILE"
    curl -fsSL https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list \
        | sed "s#deb https://#deb [signed-by=$NVIDIA_KEYRING_FILE] https://#g" \
        > "$NVIDIA_SOURCES_FILE"

    apt-get update
    apt-get install -y nvidia-container-toolkit
}

configure_nvidia_docker_runtime() {
    if docker info --format '{{json .Runtimes}}' | grep -q nvidia; then
        return 0
    fi

    log_info "Configuring Docker NVIDIA runtime"
    nvidia-ctk runtime configure --runtime=docker
    systemctl restart docker
}

ensure_gpu_support() {
    case "${GPU_VENDOR:-}" in
        "")
            return 0
            ;;
        nvidia)
            if ! command -v nvidia-smi >/dev/null 2>&1; then
                log_warning "nvidia-smi not found, install the NVIDIA driver and reboot before running GPU stacks"
            fi
            if ! command -v nvidia-ctk >/dev/null 2>&1; then
                install_nvidia_container_toolkit
            fi
            configure_nvidia_docker_runtime
            ;;
        *)
            fail "Unsupported GPU_VENDOR: $GPU_VENDOR"
            ;;
    esac
}
