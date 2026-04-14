#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "Running quick diagnostics..."
echo
echo "Step 1: basic setup check"
if "$ROOT_DIR/scripts/check-env.sh"; then
  echo "Result: basic setup looks good."
else
  echo "Result: basic setup needs a few fixes."
fi

echo
echo "Step 2: recent serial messages (if available)"
if dmesg | rg -i "tty(USB|ACM)" | tail -n 20; then
  :
else
  echo "No serial messages were shown from dmesg in this shell."
fi

echo
echo "Step 3: Volatco-specific expectations"
cat <<'EOF'
Expected saneForth sequence and outputs:
  SERIAL LOAD    -> may first mention wrong default port
  1 PORT         -> Port_B rigs should print: Using port /dev/ttyUSB1 ok
  PLUG           -> should print: ok
  reset J4+space -> should print: G144A12 polyFORTH development system
EOF

echo
echo "Step 4: ModemManager check"
if pgrep -x ModemManager >/dev/null 2>&1; then
  echo "Notice: ModemManager is running."
  echo "It can sometimes grab USB serial devices."
else
  echo "Good: ModemManager was not detected."
fi

echo
echo "Next step: run 'make connect'."
echo "If you get 'PORT ok' but no banner, focus on board power, J4 reset timing, and TX/RX/GND path."
