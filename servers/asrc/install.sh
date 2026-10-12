#!/usr/bin/env bash
set -euo pipefail

server_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repository_dir="$(cd "$server_dir/../.." && pwd)"

source "$repository_dir/scripts/lib/server.sh"
install_server "$server_dir"
