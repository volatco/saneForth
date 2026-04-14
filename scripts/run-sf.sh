#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SF_DIR="$ROOT_DIR/af3/sfux"

cd "$SF_DIR"

if [[ ! -x ./afk ]]; then
  chmod 755 ./afk
fi

if [[ ! -x ./sf6a0.exe ]]; then
  chmod 755 ./sf6a0.exe
fi

exec ./afk sf6a0.exe
