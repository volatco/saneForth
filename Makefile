SHELL := /usr/bin/env bash

.PHONY: check-env run connect

check-env:
	./scripts/check-env.sh

run:
	./scripts/run-sf.sh

connect:
	./scripts/connect-volatco.sh
