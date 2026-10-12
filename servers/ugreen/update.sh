#!/usr/bin/env bash
set -euo pipefail

main() {
    local server_dir repository_dir repository_owner

    server_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    repository_dir="$(cd "$server_dir/../.." && pwd)"
    repository_owner="$(stat -c %U "$repository_dir")"

    if ! runuser -u "$repository_owner" -- git -C "$repository_dir" pull --ff-only; then
        printf '[labnet] warning: git pull failed, using current files\n' >&2
    fi

    source "$repository_dir/scripts/lib/server.sh"
    update_server "$server_dir"
}

main "$@"
