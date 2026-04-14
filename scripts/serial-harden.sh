#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RULE_SRC="$ROOT_DIR/udev/99-volatco-ftdi.rules"
RULE_DST="/etc/udev/rules.d/99-volatco-ftdi.rules"

echo "Volatco serial hardening helper"
echo
echo "This will configure:"
echo "- ModemManager ignore for Volatco Port_B FTDI adapter"
echo "- FTDI latency_timer=1 for the adapter"
echo "- Stable alias: /dev/volatco-port-b"
echo "- Stable alias: /dev/volatco-runtime"
echo

if [[ ! -f "$RULE_SRC" ]]; then
  echo "Missing rules file: $RULE_SRC"
  exit 1
fi

echo "Detected adapter(s):"
if compgen -G "/dev/serial/by-id/*VOLATCO_Port_B*" > /dev/null; then
  ls -l /dev/serial/by-id/*VOLATCO_Port_B*
else
  echo "No /dev/serial/by-id/*VOLATCO_Port_B* entry found right now."
fi
echo

echo "Commands to apply (requires sudo):"
echo "  sudo cp \"$RULE_SRC\" \"$RULE_DST\""
echo "  sudo udevadm control --reload-rules"
echo "  sudo udevadm trigger --subsystem-match=tty --subsystem-match=usb-serial"
echo "  sudo systemctl restart ModemManager"
echo
echo "Then verify:"
echo "  ls -l /dev/volatco-port-b /dev/volatco-runtime /dev/serial/by-id/*VOLATCO_Port_B*"
echo "  cat /sys/bus/usb-serial/devices/ttyUSB*/latency_timer"
echo
echo "Note: this script prints safe apply steps and does not modify /etc by itself."
