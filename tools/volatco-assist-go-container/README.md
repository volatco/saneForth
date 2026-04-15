# volatco-assist-go-container

Container workspace for `tools/volatco-assist-go/main.go`.

## Standard image

```bash
podman build -f tools/volatco-assist-go-container/Dockerfile -t volatco-assist-go:dev .
```

## UID/GID-matched dev image

```bash
podman build \
  -f tools/volatco-assist-go-container/Containerfile.dev \
  --build-arg LOCAL_UID="$(id -u)" \
  --build-arg LOCAL_GID="$(id -g)" \
  -t volatco-assist-go:dev-keepid .
```

Or via Makefile:

```bash
make podman-build
```

## Run against host repo + serial device

```bash
podman run --rm -it \
  --userns=keep-id \
  --group-add keep-groups \
  --device /dev/ttyUSB0:/dev/ttyUSB0 \
  --volume /dev/serial/by-id:/dev/serial/by-id:ro \
  -v "$(git rev-parse --show-toplevel)":/workspace:Z \
  -w /workspace \
  volatco-assist-go:dev-keepid --json
```

Or via Makefile:

```bash
make podman-check
```

## Pod workflow for interactive polyForth

Build pod runtime image (includes i386 libs needed by `af3/sfux/sf6a0.exe`):

```bash
make podman-pod-build
```

Start (or restart) long-running pod container:

```bash
make podman-pod-up
```

Open interactive shell in container:

```bash
make podman-pod-shell
```

This starts saneForth immediately (`/workspace/scripts/run-sf.sh`).

If you want a plain bash shell in `/workspace/af3/sfux`:

```bash
make podman-pod-bash
```

From there you can launch manually:

```bash
./afk sf6a0.exe
```

Inside container, run:

```bash
./scripts/run-sf.sh
```

Or run directly without opening shell:

```bash
make podman-pod-run
make podman-pod-connect
```

Stop and remove pod resources:

```bash
make podman-pod-down
```

Notes:
- Mounting the repo root at `/workspace` is required because the app detects repo root by locating `af3/sfux/sf6a0.exe` upward from cwd.
- Add/remove `--device` flags to match your host hardware.
- `/dev/serial/by-id` is a directory, so mount it with `--volume` (not `--device`).
- If your host does not have `/dev/serial/by-id`, omit that `--volume` argument.
- If device permissions still fail, verify your host user is in `dialout` and relogin.
- In containers, missing i386 packages are reported as `WARN` (container mode), not `FAIL`.
- Override defaults for non-standard devices, for example:
  `make podman-check PODMAN_TTYUSB=/dev/ttyUSB1 PODMAN_SERIAL_BY_ID=/dev/serial/by-id`
- Pod target overrides, for example:
  `make podman-pod-up PODMAN_TTYUSB=/dev/ttyUSB1 PODMAN_POD_NAME=volatco-dev`
- `make podman-pod-up` auto-maps detected `/dev/ttyUSB0` and `/dev/ttyUSB1` when present.
