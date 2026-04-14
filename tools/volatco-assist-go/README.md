# volatco-assist-go (prototype)

Go prototype for Day 1/2 modernization exploration.

This tool is additive. It does not modify FORTH media or replace existing `make` workflows.

## What it checks

- saneForth runtime binary presence (`af3/sfux/sf6a0.exe`)
- `dialout` group membership
- serial device visibility (`/dev/ttyUSB*`)
- stable serial paths (`/dev/serial/by-id`, if available)
- required i386 packages on Debian/Ubuntu (`dpkg-query`)
- preferred runtime port command (`0 PORT` / `1 PORT` / etc.)

## Run

From repo root:

```bash
go run ./tools/volatco-assist-go
```

JSON output:

```bash
go run ./tools/volatco-assist-go --json
```

Manual port override:

```bash
VOLATCO_PORT_IDX=0 go run ./tools/volatco-assist-go
```

## Exit codes

- `0`: no failing checks
- `1`: one or more failing checks
- `2`: internal execution error (for example repo root detection failure)
