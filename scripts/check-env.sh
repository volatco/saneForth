#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SF_DIR="$ROOT_DIR/af3/sfux"
SF_BIN="$SF_DIR/sf6a0.exe"
SERIAL_BY_ID_DIR="/dev/serial/by-id"

fail=0

echo "Checking your setup..."
echo "Repo: $ROOT_DIR"

if [[ ! -f "$SF_BIN" ]]; then
  echo
  echo "Could not find the runtime file:"
  echo "  $SF_BIN"
  echo "Please confirm you are in the saneForth repo."
  exit 1
fi

echo
echo "Found runtime file:"
file "$SF_BIN" || true

if id -nG | tr ' ' '\n' | rg -qx "dialout"; then
  echo
  echo "Good: your user is in the 'dialout' group."
else
  echo
  echo "Action needed: your user is not in the 'dialout' group."
  echo "Serial access to /dev/ttyUSB* may fail."
  fail=1
fi

if compgen -G "/dev/ttyUSB*" > /dev/null; then
  echo
  echo "Found serial device(s):"
  ls -l /dev/ttyUSB*
else
  echo
  echo "Action needed: no /dev/ttyUSB* device was found."
  echo "Check cable, power, and adapter connection."
  fail=1
fi

echo
echo "Volatco adapter mapping:"
if [[ -d "$SERIAL_BY_ID_DIR" ]]; then
  if ls -l "$SERIAL_BY_ID_DIR" >/dev/null 2>&1; then
    ls -l "$SERIAL_BY_ID_DIR"
  else
    echo "No entries in $SERIAL_BY_ID_DIR right now."
  fi
else
  echo "$SERIAL_BY_ID_DIR is not available on this system."
fi

for p in libncurses6:i386 libc6:i386 libstdc++6:i386; do
  if dpkg-query -W -f='${Status}\n' "$p" 2>/dev/null | rg -q "install ok installed"; then
    echo "Good: package installed -> $p"
  else
    echo "Action needed: package missing -> $p"
    fail=1
  fi
done

if (( fail != 0 )); then
  echo
  echo "Setup check finished: some items still need attention."
  echo "After fixing them, run: make check-env"
  exit 1
fi

echo
echo "Setup check finished: everything looks ready."
echo "Next: run 'make connect' and follow the Volatco sequence."
