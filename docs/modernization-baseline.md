# Modernization Baseline (Day 1)

Captured on: `2026-04-14T17:55:32+02:00`

## Method

- 5 runs each for `make check-env` and `make doctor`
- 1 bounded probe for `make connect` using `timeout 8s`
- Timing collected in milliseconds via shell timestamps
- Raw log: `/tmp/day1-baseline-raw.txt`

## Results

| Command | Runs | Avg (ms) | Min (ms) | Max (ms) | Failures |
|---|---:|---:|---:|---:|---:|
| `make check-env` | 5 | 172.6 | 133 | 256 | 0 |
| `make doctor` | 5 | 164.6 | 158 | 171 | 0 |
| `make connect` (bounded) | 1 | 198.0 | 198 | 198 | 1 |

Per-run timings:

- `make check-env`: `138, 190, 256, 146, 133` ms
- `make doctor`: `164, 166, 158, 164, 171` ms
- `make connect` bounded probe: `198` ms (exit `2`)

## Environment observations

- `dialout` group present for current user.
- Detected serial device: `/dev/ttyUSB1` (symlink to `/dev/ttyUSB0` on this host).
- `/dev/serial/by-id` was not available in this environment.
- i386 package checks passed: `libncurses6:i386`, `libc6:i386`, `libstdc++6:i386`.

## Known blockers from Day 1 run

- `make doctor` could not read kernel buffer for serial history:
  - `dmesg: read kernel buffer failed: Operation not permitted`
- `make connect` runtime launch failed in this execution environment:
  - non-interactive run: `stty: 'standard input': Inappropriate ioctl for device`
  - PTY run: `afk: ... Bad system call (core dumped)`

Because of this, Day 1 captured only connect preflight output, not a full in-runtime golden transcript.

## Next action

- Run one interactive terminal session for full golden transcript capture of:
  - `HI`
  - `DISKS` verification
  - `SERIAL LOAD`
  - `1 PORT`
  - `PLUG`
  - reset + space
  - `20 DRIVE HI`
