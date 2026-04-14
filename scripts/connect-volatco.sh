#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cat <<'EOF'
Volatco connect checklist (run inside saneForth):

1. HI
2. DISKS
   - Verify ../projects/VOLATCO/... paths are active
3. If not, run:
   &INCLUDE ../Projects/VOLATCO/custom.txt
   DISKS
4. SERIAL LOAD
5. 0 PORT      (or 1 PORT if your USB index differs)
6. PLUG
7. Press Enter, reset J4 briefly, then press Space
8. On banner "G144A12 polyFORTH development system":
   20 DRIVE HI

Troubleshooting:
- id                     (must include dialout)
- dmesg | grep tty       (confirm ttyUSB assignment)
EOF

echo
echo "Launching saneForth runtime..."
exec "$ROOT_DIR/scripts/run-sf.sh"
