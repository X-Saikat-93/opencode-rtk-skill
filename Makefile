SHELL := /usr/bin/env bash

.PHONY: test lint package help

help:
	@echo "make test    - run local validation"
	@echo "make lint    - run shellcheck if available"
	@echo "make package - create release zip and checksum"

test:
	@bash -n install.sh
	@bash -n uninstall.sh
	@bash -n scripts/verify.sh
	@bash -n scripts/print-targets.sh
	@bash -n skills/rtk-token-saver/scripts/check-rtk.sh
	@sha256sum -c checksums.sha256
	@./tests/test-install-uninstall.sh

lint: test
	@if command -v shellcheck >/dev/null 2>&1; then \
		shellcheck install.sh uninstall.sh scripts/*.sh tests/*.sh skills/rtk-token-saver/scripts/*.sh; \
	else \
		echo "shellcheck not installed; skipped"; \
	fi

package:
	@cd .. && zip -r opencode-rtk-skill-v4.0.0.zip opencode-rtk-skill -x "opencode-rtk-skill/.git/*"
	@cd .. && sha256sum opencode-rtk-skill-v4.0.0.zip > opencode-rtk-skill-v4.0.0.zip.sha256
