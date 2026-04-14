SHELL := /usr/bin/env bash

.PHONY: check-env doctor run connect serial-harden

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
