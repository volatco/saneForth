# Agent Operating Guide

This repository contains legacy FORTH block-media workflows. Treat it as stateful system media plus docs/tooling.

## Canonical commands

- `make check-env` - verify host prerequisites and serial visibility
- `make run` - launch saneForth runtime
- `make connect` - launch saneForth with Volatco connection checklist

## Branch policy

- `main` is the historical baseline and should remain unchanged by modernization work.
- `chore/minimal-modernization` is the long-lived branch for modern docs/tooling/agent workflow.
- Do not merge modernization branch changes into `main` unless explicitly requested by maintainers.

## Required safety rules

- Do not mass-edit or format `af3/sfux/*` media files.
- Do not line-edit `Projects/*/*.src`, `Project`, `4THDISK`, `*.blk`, `OBJ-*`, `conc`.
- Assume runtime sessions will dirty tracked media files; this is expected state.
- Keep changes narrowly scoped and documentation-first unless explicitly asked to alter runtime media.

## Volatco integration check

Inside saneForth, always validate project context before serial actions:

1. `DISKS`
2. confirm `../projects/VOLATCO/...`
3. if missing: `&INCLUDE ../Projects/VOLATCO/custom.txt`

Then proceed with `SERIAL LOAD`, `0 PORT`/`1 PORT`, `PLUG`, reset, space.
