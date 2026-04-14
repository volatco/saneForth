# Contributing

## Scope

This repository contains legacy FORTH block-media workflows. Please treat block images and runtime artifacts as system media, not normal line-based source files.

## Do not edit block media with text editors

Do not open/save these files in normal editors:

- `af3/sfux/Project`, `af3/sfux/Projback`
- `af3/sfux/4THDISK`, `af3/sfux/4THBACK`, `af3/sfux/4THD-*`
- `af3/sfux/*.blk`, `af3/sfux/OBJ-*`, `af3/sfux/crud`, `af3/sfux/scratch`
- `Projects/*/*.src`, `Projects/*/OBJ-*`, `Projects/*/conc`

Use the FORTH environment and project workflows to modify content safely.

## Pull requests

- Keep changes narrowly scoped.
- Document the tested environment (distribution and package versions if relevant).
- Include exact steps to reproduce for runtime or serial behavior changes.
- If a change touches project media mappings, update both project docs and notes.

## Safety

- Preserve existing unknown/legacy behavior unless the change explicitly targets it.
- Avoid mass formatting or line-ending conversions across the repository.
