SHELL := /bin/bash

APP_NAME := clank
PKG_DIR := claude-docker-kit
DIST_DIR := dist
VERSION_FILE := VERSION
VERSION ?= $(shell cat $(VERSION_FILE) 2>/dev/null || echo 0.0.0-dev)
ARCHIVE_BASENAME := $(PKG_DIR)-$(VERSION)
PACKAGE_FILES := Dockerfile README.md install.sh clank .dockerignore Makefile VERSION

.PHONY: help package zip tar clean check install version set-version

help:
	@echo "Targets:"
	@echo "  make check                 - verify required files exist"
	@echo "  make version               - print current version"
	@echo "  make set-version VERSION=X - update VERSION file"
	@echo "  make zip                   - create dist/$(ARCHIVE_BASENAME).zip"
	@echo "  make tar                   - create dist/$(ARCHIVE_BASENAME).tar.gz"
	@echo "  make package               - create both zip and tar.gz archives"
	@echo "  make clean                 - remove dist/"
	@echo "  make install               - run ./install.sh"

check:
	@for f in $(PACKAGE_FILES); do \
		[[ -f $$f ]] || { echo "Missing required file: $$f" >&2; exit 1; }; \
	done

version:
	@cat $(VERSION_FILE)

set-version:
	@test -n "$(VERSION)" || { echo "VERSION is required" >&2; exit 1; }
	@printf '%s\n' "$(VERSION)" > $(VERSION_FILE)
	@echo "Updated $(VERSION_FILE) to $(VERSION)"

$(DIST_DIR):
	@mkdir -p $(DIST_DIR)

zip: check | $(DIST_DIR)
	@tmpdir="$$(mktemp -d)"; \
	trap 'rm -rf "$$tmpdir"' EXIT; \
	mkdir -p "$$tmpdir/$(PKG_DIR)"; \
	cp $(PACKAGE_FILES) "$$tmpdir/$(PKG_DIR)/"; \
	cd "$$tmpdir" && zip -qr "$(CURDIR)/$(DIST_DIR)/$(ARCHIVE_BASENAME).zip" "$(PKG_DIR)"


tar: check | $(DIST_DIR)
	@tmpdir="$$(mktemp -d)"; \
	trap 'rm -rf "$$tmpdir"' EXIT; \
	mkdir -p "$$tmpdir/$(PKG_DIR)"; \
	cp $(PACKAGE_FILES) "$$tmpdir/$(PKG_DIR)/"; \
	tar -C "$$tmpdir" -czf "$(DIST_DIR)/$(ARCHIVE_BASENAME).tar.gz" "$(PKG_DIR)"

package: zip tar

clean:
	rm -rf $(DIST_DIR)

install:
	./install.sh
