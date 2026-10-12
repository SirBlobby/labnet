#!/usr/bin/env bash

log_info() {
    printf '[labnet] %s\n' "$*"
}

log_warning() {
    printf '[labnet] warning: %s\n' "$*" >&2
}

fail() {
    printf '[labnet] error: %s\n' "$*" >&2
    exit 1
}

require_root() {
    if [[ "$EUID" -ne 0 ]]; then
        fail "Run this script as root (sudo $0)"
    fi
}

require_command() {
    if ! command -v "$1" >/dev/null 2>&1; then
        fail "Missing required command: $1"
    fi
}

generate_secret() {
    head -c 32 /dev/urandom | od -An -tx1 | tr -d ' \n'
}

generate_base64_key() {
    head -c 32 /dev/urandom | base64 | tr -d '\n'
}

require_real_server_values() {
    local key

    for key in "${SERVER_ENV_KEYS[@]}"; do
        if [[ "${!key}" == *example.com* ]]; then
            fail "$key still has an example value, set it in $SERVER_LOCAL_ENV_FILE"
        fi
    done
}

load_server_env() {
    local env_files env_file

    SERVER_DIR="$1"
    SERVER_ENV_FILE="$SERVER_DIR/server.env"
    SERVER_LOCAL_ENV_FILE="$SERVER_DIR/server.local.env"

    if [[ ! -f "$SERVER_ENV_FILE" ]]; then
        fail "Missing server settings file: $SERVER_ENV_FILE"
    fi

    env_files=("$SERVER_ENV_FILE")
    if [[ -f "$SERVER_LOCAL_ENV_FILE" ]]; then
        env_files+=("$SERVER_LOCAL_ENV_FILE")
    fi

    set -a
    for env_file in "${env_files[@]}"; do
        source "$env_file"
    done
    set +a

    mapfile -t SERVER_ENV_KEYS < <(grep -ohE '^[A-Za-z_][A-Za-z0-9_]*=' "${env_files[@]}" | tr -d '=' | awk '!seen[$0]++')

    require_real_server_values

    if [[ -z "${SERVER_NAME:-}" ]]; then
        fail "SERVER_NAME is not set in $SERVER_ENV_FILE"
    fi
    if [[ -z "${STACKS_DIR:-}" ]]; then
        fail "STACKS_DIR is not set in $SERVER_ENV_FILE"
    fi
    if [[ -z "${STACKS:-}" ]]; then
        fail "STACKS is not set in $SERVER_ENV_FILE"
    fi
}
