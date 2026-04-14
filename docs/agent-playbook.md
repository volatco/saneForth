# Agent Playbook

## 1) Host boot smoke test

1. `make check-env`
2. `make run`
3. At `hi`: `HI`
4. Confirm with `WHO` -> `WHO sF on x86.  ok`

## 2) Volatco connect flow

1. `make connect`
2. In saneForth:
   - `HI`
   - `DISKS` (verify Volatco paths)
   - optional: `&INCLUDE ../Projects/VOLATCO/custom.txt`
   - `SERIAL LOAD`
   - `1 PORT` (Port_B bench)
   - `PLUG`
   - Enter + reset + Space
3. On banner: `20 DRIVE HI`

## 3) Decision tree when no banner appears

1. `id` missing `dialout`:
   - add user to `dialout`, refresh login session
2. no `/dev/ttyUSB*`:
   - cable/power/adapter issue, inspect `dmesg | grep tty`
3. `PORT can't open it!`:
   - wrong port index or permissions
4. `PORT ok` but no banner:
   - board power/reset timing, TX/RX path, target boot state

## 4) State handling

- Runtime updates tracked media by design.
- Keep runtime-state artifacts local unless a change intentionally updates project media.
