#!/usr/bin/env zsh
# Unit tests for .github/workflows/*.yml
#
# Validates that every workflow:
#   1. Is parseable as YAML
#   2. Has a `name`, `on`, and `jobs` top-level field
#   3. Uses up-to-date action versions where we can detect them
#   4. References paths and files that actually exist

TEST_DIR="$(cd "$(dirname "$(dirname "$(dirname "$0")")")" && pwd)"
DOTFILES_DIR="$(dirname "$TEST_DIR")"

export TEST_TMP_DIR="${TEST_TMP_DIR:-/tmp/dotfiles_test_$$}"
mkdir -p "$TEST_TMP_DIR"

source "${TEST_DIR}/lib/test_helpers.zsh"

readonly WORKFLOWS_DIR="${DOTFILES_DIR}/.github/workflows"

# ============================================================================
# Discovery
# ============================================================================

test_workflows_directory_exists() {
  test_case ".github/workflows directory exists"
  if [[ -d "$WORKFLOWS_DIR" ]]; then
    pass
  else
    fail "workflows directory not found: $WORKFLOWS_DIR"
  fi
}

test_workflows_directory_not_empty() {
  test_case "workflows directory contains YAML files"
  local count
  count=$(find "$WORKFLOWS_DIR" -name "*.yml" -o -name "*.yaml" 2>/dev/null | wc -l | tr -d ' ')
  if [[ "$count" -gt 0 ]]; then
    pass
  else
    fail "no workflow YAML files found"
  fi
}

# ============================================================================
# Per-file YAML parse
# ============================================================================

test_all_workflows_parse_as_yaml() {
  test_case "Every workflow YAML parses cleanly"
  if ! command -v python3 >/dev/null 2>&1; then
    skip "python3 not installed"
    return
  fi

  # Verify PyYAML is available before running per-file checks.
  if ! python3 -c "import yaml" 2>/dev/null; then
    skip "PyYAML not installed"
    return
  fi

  local failed=()
  local file
  # Use null_glob so that missing extensions don't cause a no-match
  # error in zsh (the workflows dir only has .yml, not .yaml).
  setopt local_options null_glob
  for file in "$WORKFLOWS_DIR"/*.yml "$WORKFLOWS_DIR"/*.yaml; do
    [[ -f "$file" ]] || continue
    # Pass the filename via argv rather than string interpolation so
    # paths with spaces or special characters parse correctly.
    if ! python3 -c "
import sys, yaml
with open(sys.argv[1]) as f:
    yaml.safe_load(f)
" "$file" 2>/dev/null; then
      failed+=("$(basename "$file")")
    fi
  done

  if (( ${#failed[@]} == 0 )); then
    pass
  else
    fail "Workflows that failed YAML parse: ${failed[*]}"
  fi
}

# ============================================================================
# Required top-level fields
# ============================================================================

test_all_workflows_have_required_keys() {
  test_case "Every workflow has name, on, and jobs"
  local failed=()
  local file basename_no_ext
  # Use null_glob so that missing extensions don't cause a no-match
  # error in zsh (the workflows dir only has .yml, not .yaml).
  setopt local_options null_glob
  for file in "$WORKFLOWS_DIR"/*.yml "$WORKFLOWS_DIR"/*.yaml; do
    [[ -f "$file" ]] || continue
    basename_no_ext="$(basename "$file")"

    if ! grep -q "^name:" "$file" 2>/dev/null; then
      failed+=("$basename_no_ext (missing name)")
      continue
    fi
    if ! grep -q "^on:" "$file" 2>/dev/null; then
      failed+=("$basename_no_ext (missing on)")
      continue
    fi
    if ! grep -q "^jobs:" "$file" 2>/dev/null; then
      failed+=("$basename_no_ext (missing jobs)")
      continue
    fi
  done

  if (( ${#failed[@]} == 0 )); then
    pass
  else
    fail "${failed[*]}"
  fi
}

# ============================================================================
# Modern action versions
# ============================================================================

test_uses_modern_checkout_action() {
  test_case "All workflows use actions/checkout v4 or newer"
  local failed=()
  local file matches
  setopt local_options null_glob
  for file in "$WORKFLOWS_DIR"/*.yml "$WORKFLOWS_DIR"/*.yaml; do
    [[ -f "$file" ]] || continue
    matches=$(grep -E "uses:.*actions/checkout@v[0-3]([^0-9]|$)" "$file" 2>/dev/null)
    if [[ -n "$matches" ]]; then
      failed+=("$(basename "$file"): $matches")
    fi
  done

  if (( ${#failed[@]} == 0 )); then
    pass
  else
    fail "${failed[*]}"
  fi
}

test_uses_modern_cache_action() {
  test_case "All workflows use actions/cache v4 or newer"
  local failed=()
  local file matches
  setopt local_options null_glob
  for file in "$WORKFLOWS_DIR"/*.yml "$WORKFLOWS_DIR"/*.yaml; do
    [[ -f "$file" ]] || continue
    matches=$(grep -E "uses:.*actions/cache@v[0-3]([^0-9]|$)" "$file" 2>/dev/null)
    if [[ -n "$matches" ]]; then
      failed+=("$(basename "$file"): $matches")
    fi
  done

  if (( ${#failed[@]} == 0 )); then
    pass
  else
    fail "${failed[*]}"
  fi
}

# ============================================================================
# Path references
# ============================================================================

# A workflow that refers to src/<foo> should not point at a path that
# does not exist in the repo. This catches stale paths after refactoring.
# We only check src/, not test/ or config/, because those frequently
# refer to runtime paths under $HOME (e.g. ~/.config/nvim, test/logs/)
# rather than repo files.
test_workflow_paths_resolve() {
  test_case "Workflow src/ path references resolve"
  local failed=()
  local file refs
  setopt local_options null_glob
  for file in "$WORKFLOWS_DIR"/*.yml "$WORKFLOWS_DIR"/*.yaml; do
    [[ -f "$file" ]] || continue
    # Extract src/... references that look like real file paths
    # (must start with `src/` followed by a non-empty path component).
    refs=$(grep -oE "\bsrc/[a-zA-Z0-9_/-][a-zA-Z0-9_./-]*" "$file" 2>/dev/null \
      | sort -u)
    while IFS= read -r ref; do
      [[ -z "$ref" ]] && continue
      # Strip trailing punctuation that might have been captured.
      ref="${ref%[\`,\'\"]}"
      # Strip trailing slash so we can check both file and dir.
      ref="${ref%/}"
      if [[ ! -e "$DOTFILES_DIR/$ref" ]]; then
        failed+=("$(basename "$file"): $ref")
      fi
    done <<<"$refs"
  done

  if (( ${#failed[@]} == 0 )); then
    pass
  else
    fail "Broken workflow path refs: ${failed[*]}"
  fi
}

# ============================================================================
# Run tests
# ============================================================================

test_suite "GitHub workflows" \
  test_workflows_directory_exists \
  test_workflows_directory_not_empty \
  test_all_workflows_parse_as_yaml \
  test_all_workflows_have_required_keys \
  test_uses_modern_checkout_action \
  test_uses_modern_cache_action \
  test_workflow_paths_resolve
