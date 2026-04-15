SHELL := /usr/bin/env bash

PODMAN_IMAGE ?= volatco-assist-go:dev-keepid
PODMAN_TTYUSB ?= /dev/ttyUSB0
PODMAN_SERIAL_BY_ID ?= /dev/serial/by-id
PODMAN_POD_IMAGE ?= volatco-sf-runtime:dev
PODMAN_POD_NAME ?= volatco-sf-pod
PODMAN_POD_CONTAINER ?= volatco-sf-dev

.PHONY: check-env doctor run connect serial-harden podman-build podman-check \
	podman-pod-build podman-pod-up podman-pod-shell podman-pod-run \
	podman-pod-connect podman-pod-down

check-env:
	./scripts/check-env.sh

doctor:
	./scripts/doctor.sh

run:
	./scripts/run-sf.sh

connect:
	./scripts/connect-volatco.sh

serial-harden:
	./scripts/serial-harden.sh

podman-build:
	podman build \
		-f tools/volatco-assist-go-container/Containerfile.dev \
		--build-arg LOCAL_UID="$$(id -u)" \
		--build-arg LOCAL_GID="$$(id -g)" \
		-t $(PODMAN_IMAGE) .

podman-check:
	@BYID_ARG=""; \
	HOST_REPO_ROOT="$$(git rev-parse --show-toplevel 2>/dev/null || pwd)"; \
	if [ -d "$(PODMAN_SERIAL_BY_ID)" ]; then \
		BYID_ARG="--volume $(PODMAN_SERIAL_BY_ID):$(PODMAN_SERIAL_BY_ID):ro"; \
	fi; \
	podman run --rm -it \
		--userns=keep-id \
		--group-add keep-groups \
		--device $(PODMAN_TTYUSB):$(PODMAN_TTYUSB) \
		$$BYID_ARG \
		-v "$$HOST_REPO_ROOT":/workspace:Z \
		-w /workspace \
		$(PODMAN_IMAGE) --json

podman-pod-build:
	podman build \
		-f tools/volatco-assist-go-container/Containerfile.pod \
		--build-arg LOCAL_UID="$$(id -u)" \
		--build-arg LOCAL_GID="$$(id -g)" \
		-t $(PODMAN_POD_IMAGE) .

podman-pod-up:
	@HOST_REPO_ROOT="$$(git rev-parse --show-toplevel 2>/dev/null || pwd)"; \
	DEV_ARG=""; \
	BYID_ARG=""; \
	if [ -e "$(PODMAN_TTYUSB)" ]; then \
		DEV_ARG="--device $(PODMAN_TTYUSB):$(PODMAN_TTYUSB)"; \
	else \
		echo "warning: $(PODMAN_TTYUSB) not found; starting pod container without ttyUSB mapping"; \
	fi; \
	if [ -d "$(PODMAN_SERIAL_BY_ID)" ]; then \
		BYID_ARG="--volume $(PODMAN_SERIAL_BY_ID):$(PODMAN_SERIAL_BY_ID):ro"; \
	fi; \
	if ! podman pod exists $(PODMAN_POD_NAME); then \
		podman pod create --name $(PODMAN_POD_NAME); \
	fi; \
	if podman container exists $(PODMAN_POD_CONTAINER); then \
		podman start $(PODMAN_POD_CONTAINER); \
	else \
		podman run -d \
			--name $(PODMAN_POD_CONTAINER) \
			--pod $(PODMAN_POD_NAME) \
			--group-add keep-groups \
			$$DEV_ARG \
			$$BYID_ARG \
			-v "$$HOST_REPO_ROOT":/workspace:Z \
			-w /workspace \
			$(PODMAN_POD_IMAGE); \
	fi

podman-pod-shell:
	podman exec -it $(PODMAN_POD_CONTAINER) bash

podman-pod-run:
	podman exec -it $(PODMAN_POD_CONTAINER) ./scripts/run-sf.sh

podman-pod-connect:
	podman exec -it $(PODMAN_POD_CONTAINER) ./scripts/connect-volatco.sh

podman-pod-down:
	-podman rm -f $(PODMAN_POD_CONTAINER)
	-podman pod rm -f $(PODMAN_POD_NAME)
