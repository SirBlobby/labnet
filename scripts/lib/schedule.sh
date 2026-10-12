#!/usr/bin/env bash

install_update_timer() {
    local unit_name="labnet-update-$SERVER_NAME"
    local service_file="/etc/systemd/system/$unit_name.service"
    local timer_file="/etc/systemd/system/$unit_name.timer"

    if [[ -z "${UPDATE_SCHEDULE:-}" ]]; then
        log_info "UPDATE_SCHEDULE is empty, automatic updates are disabled"
        return 0
    fi

    cat > "$service_file" <<EOF
[Unit]
Description=Lab Net update for $SERVER_NAME
Wants=network-online.target
After=network-online.target docker.service

[Service]
Type=oneshot
ExecStart=/usr/bin/env bash $SERVER_DIR/update.sh
EOF

    cat > "$timer_file" <<EOF
[Unit]
Description=Scheduled Lab Net update for $SERVER_NAME

[Timer]
OnCalendar=$UPDATE_SCHEDULE
Persistent=true
RandomizedDelaySec=15m

[Install]
WantedBy=timers.target
EOF

    systemctl daemon-reload
    systemctl enable --now "$unit_name.timer" >/dev/null 2>&1
    log_info "Automatic updates scheduled: $UPDATE_SCHEDULE"
}
