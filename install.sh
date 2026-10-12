#!/usr/bin/env bash
set -euo pipefail

repository_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
server_name="${1:-}"
server_install_script="$repository_dir/servers/$server_name/install.sh"

if [[ -z "$server_name" || ! -f "$server_install_script" ]]; then
    printf 'Usage: sudo bash %s <server>\n' "$0" >&2
    printf 'Available servers:\n' >&2
    for server_dir in "$repository_dir"/servers/*/; do
        printf '  %s\n' "$(basename "$server_dir")" >&2
    done
    exit 1
fi

exec bash "$server_install_script"
