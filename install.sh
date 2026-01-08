#!/bin/bash
set -euo pipefail

############################################
# Constants
############################################
ACTION="${1:-install}"

RUNTIME_URL="https://raw.githubusercontent.com/vipinuengage/syswatcher/main/syswatcher"
CTL_URL="https://raw.githubusercontent.com/vipinuengage/syswatcher/main/syswatcherctl"

BIN_RUNTIME="/usr/local/bin/syswatcher"
BIN_CTL="/usr/local/bin/syswatcherctl"

CONFIG_DIR="/etc/syswatcher"
CONFIG_FILE="$CONFIG_DIR/config.conf"

STATE_DIR="/var/lib/syswatcher"

SERVICE_FILE="/lib/systemd/system/syswatcher.service"
TIMER_FILE="/lib/systemd/system/syswatcher.timer"

############################################
# Helpers
############################################
require_root() {
  if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root."
    exit 1
  fi
}

prompt() {
  local msg="$1"
  local def="$2"
  read -rp "$msg [$def]: " val
  echo "${val:-$def}"
}

download() {
  local url="$1"
  local dest="$2"
  curl -fsSL "$url" -o "$dest"
  chmod 755 "$dest"
}

############################################
# Install
############################################
install() {
  echo "▶ Installing syswatcher..."

  mkdir -p "$CONFIG_DIR" "$STATE_DIR"
  chmod 700 "$CONFIG_DIR" "$STATE_DIR"

  if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "▶ Initial configuration"
    CPU=$(prompt "CPU threshold (%)" 80)
    RAM=$(prompt "RAM threshold (%)" 75)
    DISK=$(prompt "Disk threshold (%)" 85)
    PATHM=$(prompt "Disk mount path" "/")
    WEBHOOK=$(prompt "Google Chat webhook URL" "")
    COOL=$(prompt "Alert cooldown (seconds)" 300)

    cat > "$CONFIG_FILE" <<EOF
CPU_THRESHOLD=$CPU
RAM_THRESHOLD=$RAM
DISK_THRESHOLD=$DISK
DISK_PATH="$PATHM"
WEBHOOK_URL="$WEBHOOK"
HOSTNAME_OVERRIDE=""
COOLDOWN_SECONDS=$COOL
EOF

    chmod 600 "$CONFIG_FILE"
  else
    echo "✔ Existing config found, keeping it"
  fi

  echo "▶ Installing binaries"
  download "$RUNTIME_URL" "$BIN_RUNTIME"
  download "$CTL_URL" "$BIN_CTL"

  echo "▶ Installing systemd units"

  cat > "$SERVICE_FILE" <<EOF
[Unit]
Description=Syswatcher Resource Monitor

[Service]
Type=oneshot
ExecStart=$BIN_RUNTIME
EOF

  cat > "$TIMER_FILE" <<EOF
[Unit]
Description=Run syswatcher every minute

[Timer]
OnBootSec=1min
OnUnitActiveSec=1min
Persistent=true

[Install]
WantedBy=timers.target
EOF

  systemctl daemon-reload
  systemctl enable --now syswatcher.timer

  echo ""
  echo "✔ syswatcher installed successfully"
  echo ""
  echo "Management commands:"
  echo "  syswatcherctl status"
  echo "  syswatcherctl config edit"
  echo "  syswatcherctl update"
  echo "  syswatcherctl remove"
}

############################################
# Update
############################################
update() {
  echo "▶ Updating syswatcher..."

  systemctl stop syswatcher.timer || true

  download "$RUNTIME_URL" "$BIN_RUNTIME"
  download "$CTL_URL" "$BIN_CTL"

  systemctl start syswatcher.timer

  echo "✔ Update complete"
}

############################################
# Remove
############################################
remove() {
  echo "▶ Removing syswatcher..."

  systemctl stop syswatcher.timer || true
  systemctl disable syswatcher.timer || true

  rm -f "$BIN_RUNTIME" "$BIN_CTL"
  rm -f "$SERVICE_FILE" "$TIMER_FILE"
  rm -rf "$CONFIG_DIR" "$STATE_DIR"

  systemctl daemon-reload

  echo "✔ syswatcher removed"
}

############################################
# Entrypoint
############################################
require_root

case "$ACTION" in
  install)
    install
    ;;
  update)
    update
    ;;
  remove)
    remove
    ;;
  *)
    echo "Usage:"
    echo "  $0 install"
    echo "  $0 update"
    echo "  $0 remove"
    exit 1
    ;;
esac
