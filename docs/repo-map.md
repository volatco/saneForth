# Repository Map

## Top-level directories

- `af3/`
  - Legacy host runtime workspace and disk media in `af3/sfux/`.
  - Includes launcher scripts, terminal profiles, runtime binary, and block images.
- `Projects/`
  - Project payloads for `DEFAULT` and `VOLATCO`.
  - Contains source images (`*.src`), backups, object images, concordance, and project custom mappings.
- `designs/`
  - Mechanical design files for reset hardware/support parts.
- `experiments/`
  - High-level hardware experiment notes and examples.

## Key files

- `README.md`: Primary operator guide (runtime startup, serial workflow, provisioning steps).
- `af3/WARNING`: Platform-specific loader caveat observed on Debian Trixie VM.
- `Projects/*/custom.txt`: Project-specific media and serial mapping definitions.

## Important note

Most project code is stored in fixed-size FORTH block media, not line-oriented source files.
