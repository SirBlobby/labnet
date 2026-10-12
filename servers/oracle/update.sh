#!/usr/bin/env bash
set -euo pipefail

main() {
    local server_dir repository_dir

    server_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    repository_dir="$(cd "$server_dir/../.." && pwd)"

    if ! git -C "$repository_dir" -c safe.directory="$repository_dir" pull --ff-only; then
        printf '[labnet] warning: git pull failed, using current files\n' >&2
    fi

    source "$repository_dir/scripts/lib/server.sh"
    update_server "$server_dir"
}

main "$@"
