#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PREFERRED_PORT_CMD="1 PORT"
TTY_LIST=""
BY_ID_LIST=""

if [[ -d /dev/serial/by-id ]]; then
  BY_ID_LIST="$(ls -l /dev/serial/by-id 2>/dev/null || true)"
  if rg -q "VOLATCO_Port_B.*ttyUSB([0-9]+)" <<<"$BY_ID_LIST"; then
    tty_idx="$(rg -o "VOLATCO_Port_B.*ttyUSB([0-9]+)" -r '$1' <<<"$BY_ID_LIST" | head -n1)"
    if [[ -n "${tty_idx:-}" ]]; then
      PREFERRED_PORT_CMD="${tty_idx} PORT"
    fi
  fi
fi

if compgen -G "/dev/ttyUSB*" > /dev/null; then
  TTY_LIST="$(ls /dev/ttyUSB* | tr '\n' ' ')"
  if [[ -z "${tty_idx:-}" && -e /dev/ttyUSB1 ]]; then
    PREFERRED_PORT_CMD="1 PORT"
  elif [[ -z "${tty_idx:-}" && -e /dev/ttyUSB0 ]]; then
    PREFERRED_PORT_CMD="0 PORT"
  fi
fi

cat <<EOF
Volatco connection guide (inside saneForth):

1. HI
2. DISKS
   - Make sure you see ../projects/VOLATCO/... paths
3. If not, run:
   &INCLUDE ../Projects/VOLATCO/custom.txt
   DISKS
4. SERIAL LOAD
5. ${PREFERRED_PORT_CMD}      (Port_B rigs usually use 1 PORT)
   - expected: "Using port /dev/ttyUSBx ok"
6. PLUG
   - expected: "ok"
7. Press Enter, reset J4 briefly, then press Space
8. expected target banner: "G144A12 polyFORTH development system"
9. On banner:
   20 DRIVE HI

If it does not connect:
- Run: id                  (should include dialout)
- If "PORT can't open it!": wrong tty index or permissions
- If "PORT ok" but no banner: board power, J4 reset timing, or TX/RX/GND path
EOF

if [[ -n "$TTY_LIST" ]]; then
  echo "Detected serial device(s): $TTY_LIST"
else
  echo "No /dev/ttyUSB* device found right now."
  echo "Check cable, power, and adapter."
fi

if [[ -n "$BY_ID_LIST" ]]; then
  echo
  echo "Stable serial path(s) from /dev/serial/by-id:"
  echo "$BY_ID_LIST"
fi

echo
echo "Starting saneForth..."
exec "$ROOT_DIR/scripts/run-sf.sh"
