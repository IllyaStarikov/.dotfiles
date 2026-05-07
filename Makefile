# Dotfiles Makefile
# Usage: make <target>

SHELL := /bin/zsh

.PHONY: help test test-unit test-full fmt lint setup symlinks update theme theme-day theme-night

# Show available commands
help:
	@echo "Dotfiles Commands:"
	@echo ""
	@echo "  Testing:"
	@echo "    make test        Run quick test suite"
	@echo "    make test-unit   Run unit tests only"
	@echo "    make test-full   Run full test suite"
	@echo ""
	@echo "  Code Quality:"
	@echo "    make fmt         Format all code with fixy"
	@echo "    make lint        Run code quality smoke checks"
	@echo ""
	@echo "  Setup:"
	@echo "    make setup       Run full installation"
	@echo "    make symlinks    Create/update symlinks"
	@echo "    make update      Update packages and plugins"
	@echo ""
	@echo "  Theme:"
	@echo "    make theme       Auto-detect from macOS appearance"
	@echo "    make theme-day   Switch to light theme"
	@echo "    make theme-night Switch to dark theme"

# Run quick test suite
test:
	./test/runner.zsh --quick

# Run unit tests only
test-unit:
	./test/runner.zsh --unit

# Run full test suite
test-full:
	./test/runner.zsh --full

# Format all code with fixy
fmt:
	./src/scripts/fixy src/

# Run code quality smoke checks
lint:
	DOTFILES_DIR="$(CURDIR)" TEST_TMP_DIR="$${TEST_TMP_DIR:-/tmp/dotfiles_lint_$$$$}" ./test/smoke/code_quality_test.zsh

# Run full setup
setup:
	./src/setup/install.sh

# Create/update symlinks only
symlinks:
	./src/setup/symlinks.sh

# Update packages and plugins
update:
	./src/setup/update.sh

# Auto-detect theme from macOS appearance
theme:
	./src/scripts/theme

# Switch to light theme
theme-day:
	./src/scripts/theme day

# Switch to dark theme
theme-night:
	./src/scripts/theme night
