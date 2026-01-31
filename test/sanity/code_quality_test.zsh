#!/usr/bin/env zsh
# Sanity Tests - Code Quality Validation
# Ensures all source files pass linting and formatting checks

set -uo pipefail

source "$(dirname "$0")/../lib/test_helpers.zsh"

readonly DEBUG="${DEBUG:-0}"

echo -e "${BLUE}=== Sanity Tests - Code Quality Validation ===${NC}"

# === Lua Syntax Validation ===
test_case "Lua files have valid syntax (luac -p)"
if ! command -v luac &>/dev/null; then
  skip "luac not installed"
else
  errors=0
  lua_files=($(find "$DOTFILES_DIR/src/neovim" "$DOTFILES_DIR/src/wezterm" -name "*.lua" 2>/dev/null))

  for file in "${lua_files[@]}"; do
    if ! luac -p "$file" 2>/dev/null; then
      [[ "$DEBUG" == "1" ]] && echo "  Syntax error: $file"
      ((errors++))
    fi
  done

  if [[ $errors -eq 0 ]]; then
    pass "${#lua_files[@]} Lua files validated"
  else
    fail "$errors Lua files have syntax errors"
  fi
fi

# === Lua Formatting ===
test_case "Lua files are properly formatted (stylua)"
if ! command -v stylua &>/dev/null; then
  skip "stylua not installed"
else
  if stylua --check "$DOTFILES_DIR/src/neovim" "$DOTFILES_DIR/src/wezterm" \
    --config-path "$DOTFILES_DIR/src/language/stylua.toml" 2>/dev/null; then
    pass
  else
    fail "Lua files need formatting (run: stylua src/neovim src/wezterm)"
  fi
fi

# === Python Linting ===
test_case "Python files pass linting (ruff check)"
if ! command -v ruff &>/dev/null; then
  skip "ruff not installed"
else
  if [[ ! -d "$DOTFILES_DIR/src/cortex" ]]; then
    skip "cortex directory not found"
  else
    if ruff check "$DOTFILES_DIR/src/cortex" 2>/dev/null; then
      pass
    else
      fail "Python linting errors (run: ruff check --fix src/cortex)"
    fi
  fi
fi

# === Python Formatting ===
test_case "Python files are properly formatted (ruff format)"
if ! command -v ruff &>/dev/null; then
  skip "ruff not installed"
else
  if [[ ! -d "$DOTFILES_DIR/src/cortex" ]]; then
    skip "cortex directory not found"
  else
    if ruff format --check "$DOTFILES_DIR/src/cortex" 2>/dev/null; then
      pass
    else
      fail "Python files need formatting (run: ruff format src/cortex)"
    fi
  fi
fi

# === Zsh Syntax Validation ===
test_case "Zsh files have valid syntax (zsh -n)"
errors=0
zsh_files=($(find "$DOTFILES_DIR/src" "$DOTFILES_DIR/test" -name "*.zsh" 2>/dev/null))

for file in "${zsh_files[@]}"; do
  if ! zsh -n "$file" 2>/dev/null; then
    [[ "$DEBUG" == "1" ]] && echo "  Syntax error: $file"
    ((errors++))
  fi
done

# Also check zsh scripts without .zsh extension
zsh_scripts=($(grep -rl '^#!/usr/bin/env zsh' "$DOTFILES_DIR/src/scripts" 2>/dev/null || true))
for script in "${zsh_scripts[@]}"; do
  if ! zsh -n "$script" 2>/dev/null; then
    [[ "$DEBUG" == "1" ]] && echo "  Syntax error: $script"
    ((errors++))
  fi
done

total_zsh=$((${#zsh_files[@]} + ${#zsh_scripts[@]}))
if [[ $errors -eq 0 ]]; then
  pass "$total_zsh Zsh files validated"
else
  fail "$errors Zsh files have syntax errors"
fi

# === JSON Validation ===
test_case "JSON files are valid (jq)"
if ! command -v jq &>/dev/null; then
  skip "jq not installed"
else
  errors=0
  json_files=($(find "$DOTFILES_DIR" -name "*.json" -type f -not -path "*/.git/*" -not -path "*/node_modules/*" 2>/dev/null))

  for file in "${json_files[@]}"; do
    if ! jq . "$file" >/dev/null 2>&1; then
      [[ "$DEBUG" == "1" ]] && echo "  Invalid JSON: $file"
      ((errors++))
    fi
  done

  if [[ $errors -eq 0 ]]; then
    pass "${#json_files[@]} JSON files validated"
  else
    fail "$errors JSON files are invalid"
  fi
fi

# === TOML Validation ===
test_case "TOML files are valid (taplo)"
if ! command -v taplo &>/dev/null; then
  skip "taplo not installed"
else
  errors=0
  toml_files=($(find "$DOTFILES_DIR" -name "*.toml" -type f -not -path "*/.git/*" 2>/dev/null))

  for file in "${toml_files[@]}"; do
    if ! taplo format --check "$file" 2>/dev/null; then
      [[ "$DEBUG" == "1" ]] && echo "  Invalid TOML: $file"
      ((errors++))
    fi
  done

  if [[ $errors -eq 0 ]]; then
    pass "${#toml_files[@]} TOML files validated"
  else
    fail "$errors TOML files need formatting"
  fi
fi

# === No Tabs in Lua/YAML/JSON ===
test_case "No tabs in space-indented files"
errors=0
files_with_tabs=$(grep -rl $'\t' "$DOTFILES_DIR/src" --include="*.lua" --include="*.yml" --include="*.yaml" --include="*.json" 2>/dev/null | head -10 || true)

if [[ -n "$files_with_tabs" ]]; then
  [[ "$DEBUG" == "1" ]] && echo "$files_with_tabs" | while read -r f; do echo "  Tabs found: $f"; done
  errors=$(echo "$files_with_tabs" | wc -l | tr -d ' ')
fi

if [[ $errors -eq 0 ]]; then
  pass
else
  fail "$errors files contain tabs (should use spaces)"
fi

# === No Trailing Whitespace ===
test_case "No trailing whitespace in source files"
errors=0
files_with_trailing=$(grep -rl '[[:space:]]$' "$DOTFILES_DIR/src" "$DOTFILES_DIR/test" \
  --include="*.sh" --include="*.zsh" --include="*.lua" --include="*.py" 2>/dev/null | head -10 || true)

if [[ -n "$files_with_trailing" ]]; then
  [[ "$DEBUG" == "1" ]] && echo "$files_with_trailing" | while read -r f; do echo "  Trailing whitespace: $f"; done
  errors=$(echo "$files_with_trailing" | wc -l | tr -d ' ')
fi

if [[ $errors -eq 0 ]]; then
  pass
else
  fail "$errors files have trailing whitespace"
fi

echo -e "\n${GREEN}=== Code Quality Summary ===${NC}"
echo "Passed: $PASSED, Failed: $FAILED, Skipped: $SKIPPED"

# Exit with error if any tests failed
[[ $FAILED -eq 0 ]] || exit 1
