#!/usr/bin/env zsh
# Unit tests for symlinks.sh integrity
#
# Parses src/setup/symlinks.sh and asserts that every source path
# referenced by `create_link "$DOTFILES_DIR/<source>" ...` actually
# exists. Catches stale entries when files are moved or renamed.

TEST_DIR="$(cd "$(dirname "$(dirname "$(dirname "$0")")")" && pwd)"
DOTFILES_DIR="$(dirname "$TEST_DIR")"

export TEST_TMP_DIR="${TEST_TMP_DIR:-/tmp/dotfiles_test_$$}"
mkdir -p "$TEST_TMP_DIR"

source "${TEST_DIR}/lib/test_helpers.zsh"

readonly SYMLINKS_SH="${DOTFILES_DIR}/src/setup/symlinks.sh"

# ============================================================================
# File existence
# ============================================================================

test_symlinks_script_exists() {
  test_case "src/setup/symlinks.sh exists"
  assert_file_exists "$SYMLINKS_SH" && pass
}

test_symlinks_script_executable() {
  test_case "symlinks.sh is executable"
  assert_executable "$SYMLINKS_SH" && pass
}

test_symlinks_script_syntax() {
  test_case "symlinks.sh has valid zsh syntax"
  if zsh -n "$SYMLINKS_SH" 2>/dev/null; then
    pass
  else
    fail "symlinks.sh has syntax errors"
  fi
}

# ============================================================================
# Source-path integrity
# ============================================================================

test_all_create_link_sources_exist() {
  test_case "Every create_link source path resolves"

  # Extract source paths from `create_link "$DOTFILES_DIR/<source>"
  # "$HOME/<dest>"` calls. Skip lines inside comments.
  local -a sources
  local line
  while IFS= read -r line; do
    # Strip leading whitespace and trailing comments.
    line="${line#"${line%%[![:space:]]*}"}"
    [[ "$line" == \#* ]] && continue

    # Look for create_link "$DOTFILES_DIR/...".
    if [[ "$line" == *create_link* && "$line" == *DOTFILES_DIR* ]]; then
      # Pull out the first quoted argument.
      local src
      src=$(printf '%s' "$line" \
        | sed -nE 's/.*create_link[[:space:]]+"\$\{?DOTFILES_DIR\}?\/([^"]*)".*/\1/p')
      [[ -n "$src" ]] && sources+=("$src")
    fi
  done <"$SYMLINKS_SH"

  if (( ${#sources[@]} == 0 )); then
    fail "Could not parse any create_link entries from symlinks.sh"
    return
  fi

  local missing=()
  local src
  for src in "${sources[@]}"; do
    if [[ ! -e "$DOTFILES_DIR/$src" ]]; then
      missing+=("$src")
    fi
  done

  if (( ${#missing[@]} == 0 )); then
    pass
  else
    fail "${#missing[@]} missing sources: ${missing[*]}"
  fi
}

test_create_link_count_is_reasonable() {
  test_case "symlinks.sh creates a reasonable number of symlinks"
  local count
  count=$(grep -cE "^[[:space:]]*create_link[[:space:]]" "$SYMLINKS_SH" 2>/dev/null || echo 0)
  if (( count >= 10 )); then
    pass
  else
    fail "Only found $count create_link calls (expected at least 10)"
  fi
}

# ============================================================================
# Run tests
# ============================================================================

test_suite "symlinks.sh integrity" \
  test_symlinks_script_exists \
  test_symlinks_script_executable \
  test_symlinks_script_syntax \
  test_all_create_link_sources_exist \
  test_create_link_count_is_reasonable
