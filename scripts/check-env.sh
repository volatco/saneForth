#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SF_DIR="$ROOT_DIR/af3/sfux"
SF_BIN="$SF_DIR/sf6a0.exe"

fail=0

echo "[check] repo root: $ROOT_DIR"

if [[ ! -f "$SF_BIN" ]]; then
  echo "[fail] missing binary: $SF_BIN"
  exit 1
fi

echo "[check] runtime binary exists"
file "$SF_BIN" || true

if id -nG | tr ' ' '\n' | rg -qx "dialout"; then
  echo "[check] user is in dialout group"
else
  echo "[warn] user is not in dialout group"
  echo "       serial open to /dev/ttyUSB* may fail"
  fail=1
fi

if compgen -G "/dev/ttyUSB*" > /dev/null; then
  echo "[check] serial devices:"
  ls -l /dev/ttyUSB*
else
  echo "[warn] no /dev/ttyUSB* devices detected"
  fail=1
fi

for p in libncurses6:i386 libc6:i386 libstdc++6:i386; do
  if dpkg-query -W -f='${Status}\n' "$p" 2>/dev/null | rg -q "install ok installed"; then
    echo "[check] package installed: $p"
  else
    echo "[warn] package missing: $p"
    fail=1
  fi
done

if (( fail != 0 )); then
  echo
  echo "[result] environment has warnings; see messages above."
  exit 1
fi

echo
echo "[result] environment checks passed."
