#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PREFERRED_PORT_CMD="1 PORT"
DETECTION_REASON="default fallback"
TTY_LIST=""
BY_ID_LIST=""
tty_idx=""
RUNTIME_TTY="${VOLATCO_RUNTIME_TTY:-ttyUSB1}"
RUNTIME_DEV="/dev/${RUNTIME_TTY}"

resolve_volatco_tty_path() {
  if [[ -e /dev/volatco-port-b ]]; then
    readlink -f /dev/volatco-port-b 2>/dev/null || true
    return
  fi

  if compgen -G "/dev/serial/by-id/*VOLATCO_Port_B*" > /dev/null; then
    readlink -f /dev/serial/by-id/*VOLATCO_Port_B* 2>/dev/null | head -n1 || true
    return
  fi

  if compgen -G "/dev/serial/by-id/*VOLATCO*" > /dev/null; then
    readlink -f /dev/serial/by-id/*VOLATCO* 2>/dev/null | head -n1 || true
    return
  fi
}

heal_runtime_tty_mapping() {
  local target_tty=""
  local current_target=""

  target_tty="$(resolve_volatco_tty_path)"
  if [[ -z "${target_tty:-}" || ! -e "${target_tty:-}" ]]; then
    return
  fi

  current_target="$(readlink -f "$RUNTIME_DEV" 2>/dev/null || true)"
  if [[ "$current_target" == "$target_tty" ]]; then
    return
  fi

  # Do not clobber a kernel-created character device (real ttyUSB node).
  if [[ -e "$RUNTIME_DEV" && ! -L "$RUNTIME_DEV" ]]; then
    echo "Runtime mapping note: $RUNTIME_DEV exists as a real tty node; skipping auto-remap."
    return
  fi

  if ln -sfn "$target_tty" "$RUNTIME_DEV" 2>/dev/null; then
    echo "Runtime mapping healed: $RUNTIME_DEV -> $target_tty"
    return
  fi

  if sudo ln -sfn "$target_tty" "$RUNTIME_DEV" 2>/dev/null; then
    echo "Runtime mapping healed with sudo: $RUNTIME_DEV -> $target_tty"
    return
  fi

  echo "Runtime mapping warning: could not map $RUNTIME_DEV -> $target_tty automatically."
  echo "Try: sudo ln -sfn $target_tty $RUNTIME_DEV"
}

heal_runtime_tty_mapping

# Manual override for unstable ttyUSB numbering.
# Example: VOLATCO_PORT_IDX=0 make connect
if [[ -n "${VOLATCO_PORT_IDX:-}" ]]; then
  if [[ "${VOLATCO_PORT_IDX}" =~ ^[0-9]+$ ]]; then
    PREFERRED_PORT_CMD="${VOLATCO_PORT_IDX} PORT"
    DETECTION_REASON="manual override VOLATCO_PORT_IDX=${VOLATCO_PORT_IDX}"
    tty_idx="${VOLATCO_PORT_IDX}"
  else
    echo "Invalid VOLATCO_PORT_IDX='${VOLATCO_PORT_IDX}' (must be numeric)."
    exit 1
  fi
fi

set_preferred_port_from_path() {
  local tty_path="$1"
  local reason="$2"
  if [[ "$tty_path" =~ ttyUSB([0-9]+)$ ]]; then
    tty_idx="${BASH_REMATCH[1]}"
    PREFERRED_PORT_CMD="${tty_idx} PORT"
    DETECTION_REASON="$reason ($tty_path)"
    return 0
  fi
  return 1
}

# Priority 1: stable alias created by udev hardening.
if [[ -z "$tty_idx" && -e /dev/volatco-port-b ]]; then
  resolved="$(readlink -f /dev/volatco-port-b 2>/dev/null || true)"
  if [[ -n "${resolved:-}" ]]; then
    set_preferred_port_from_path "$resolved" "stable alias /dev/volatco-port-b" || true
  fi
fi

if [[ -d /dev/serial/by-id ]]; then
  BY_ID_LIST="$(ls -l /dev/serial/by-id 2>/dev/null || true)"
  if [[ -z "$tty_idx" ]] && compgen -G "/dev/serial/by-id/*VOLATCO_Port_B*" > /dev/null; then
    volatco_port_b="$(readlink -f /dev/serial/by-id/*VOLATCO_Port_B* 2>/dev/null | head -n1 || true)"
    if [[ -n "${volatco_port_b:-}" ]]; then
      set_preferred_port_from_path "$volatco_port_b" "by-id VOLATCO_Port_B match" || true
    fi
  fi

  if [[ -z "$tty_idx" ]] && compgen -G "/dev/serial/by-id/*VOLATCO*" > /dev/null; then
    any_volatco="$(readlink -f /dev/serial/by-id/*VOLATCO* 2>/dev/null | head -n1 || true)"
    if [[ -n "${any_volatco:-}" ]]; then
      set_preferred_port_from_path "$any_volatco" "by-id VOLATCO match" || true
    fi
  fi
fi

if compgen -G "/dev/ttyUSB*" > /dev/null; then
  TTY_LIST="$(ls /dev/ttyUSB* | tr '\n' ' ')"

  if [[ -z "$tty_idx" ]]; then
    tty_count="$(ls -1 /dev/ttyUSB* 2>/dev/null | wc -l | tr -d ' ')"
    if [[ "$tty_count" == "1" ]]; then
      only_tty="$(ls -1 /dev/ttyUSB* 2>/dev/null | head -n1 || true)"
      if [[ -n "${only_tty:-}" ]]; then
        set_preferred_port_from_path "$only_tty" "single ttyUSB device present" || true
      fi
    fi
  fi

  if [[ -z "$tty_idx" ]]; then
    last_tty="$(dmesg 2>/dev/null | rg -o "ttyUSB[0-9]+" | tail -n1 || true)"
    if [[ -n "${last_tty:-}" ]]; then
      set_preferred_port_from_path "/dev/$last_tty" "last ttyUSB seen in dmesg" || true
    fi
  fi

  if [[ -z "$tty_idx" && -e /dev/ttyUSB1 ]]; then
    PREFERRED_PORT_CMD="1 PORT"
    DETECTION_REASON="fallback to ttyUSB1 present"
  elif [[ -z "$tty_idx" && -e /dev/ttyUSB0 ]]; then
    PREFERRED_PORT_CMD="0 PORT"
    DETECTION_REASON="fallback to ttyUSB0 present"
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

echo "Autodetected runtime port: ${PREFERRED_PORT_CMD} (${DETECTION_REASON})"
echo "Legacy runtime device expected by media: ${RUNTIME_DEV}"

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
