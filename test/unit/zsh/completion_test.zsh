#!/usr/bin/env zsh
# Test: Zsh Completion and Shell Initialization
#
# Tests shell initialization and completion from src/zsh/:
#   - zshrc: Main configuration
#   - zshenv: Environment setup
#   - aliases.zsh: Command aliases
#   - Zinit plugin loading
#   - Completion system initialization
#
# Style guide: https://google.github.io/styleguide/shellguide.html

# Test environment configuration
export TEST_DIR="${TEST_DIR:-$(cd "$(dirname "$0")/../.." && pwd)}"
export DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$TEST_DIR/.." && pwd)}"
export TEST_TMP_DIR="${TEST_TMP_DIR:-/tmp/dotfiles-test-$$}"

# Source test framework
source "$TEST_DIR/lib/test_helpers.zsh"

# Setup test
setup_test

describe "Zsh Completion and Shell Initialization Tests"

readonly ZSH_DIR="$DOTFILES_DIR/src/zsh"

# =============================================================================
# FILE EXISTENCE
# =============================================================================

test_case "Zsh configuration files exist"
zsh_files=(
  "zshrc"
  "zshenv"
  "aliases.zsh"
)

all_exist=true
for file in "${zsh_files[@]}"; do
  if [[ ! -f "$ZSH_DIR/$file" ]]; then
    fail "Missing: $file"
    all_exist=false
  fi
done
if $all_exist; then
  pass
fi

# =============================================================================
# SYNTAX VALIDATION
# =============================================================================

test_case "zshrc has valid syntax"
if zsh -n "$ZSH_DIR/zshrc" 2>/dev/null; then
  pass
else
  fail "Syntax error in zshrc"
fi

test_case "zshenv has valid syntax"
if zsh -n "$ZSH_DIR/zshenv" 2>/dev/null; then
  pass
else
  fail "Syntax error in zshenv"
fi

test_case "aliases.zsh has valid syntax"
if zsh -n "$ZSH_DIR/aliases.zsh" 2>/dev/null; then
  pass
else
  fail "Syntax error in aliases.zsh"
fi

# =============================================================================
# ZSHRC CONFIGURATION
# =============================================================================

test_case "zshrc sets essential options"
options=("AUTO_CD" "INTERACTIVE_COMMENTS" "HIST_IGNORE_DUPS" "SHARE_HISTORY")
found=0
for opt in "${options[@]}"; do
  if grep -q "$opt" "$ZSH_DIR/zshrc"; then
    ((found++))
  fi
done
if [[ $found -ge 3 ]]; then
  pass
else
  fail "Missing essential zsh options"
fi

test_case "zshrc configures history"
if grep -q "HISTFILE\|HISTSIZE\|SAVEHIST" "$ZSH_DIR/zshrc"; then
  pass
else
  fail "History configuration missing"
fi

test_case "zshrc uses Zinit plugin manager"
if grep -q "zinit" "$ZSH_DIR/zshrc"; then
  pass
else
  fail "Zinit plugin manager not configured"
fi

test_case "zshrc skips global compinit"
if grep -q "skip_global_compinit" "$ZSH_DIR/zshrc"; then
  pass
else
  fail "Should skip global compinit for performance"
fi

# =============================================================================
# COMPLETION SYSTEM
# =============================================================================

test_case "Completion system is initialized"
if grep -q "compinit" "$ZSH_DIR/zshrc"; then
  pass
else
  fail "compinit should be called"
fi

test_case "zsh-completions plugin is loaded"
if grep -q "zsh-users/zsh-completions\|zsh-completions" "$ZSH_DIR/zshrc"; then
  pass
else
  fail "zsh-completions plugin should be loaded"
fi

test_case "bashcompinit is enabled for compatibility"
if grep -q "bashcompinit" "$ZSH_DIR/zshrc"; then
  pass
else
  fail "bashcompinit should be enabled"
fi

# =============================================================================
# PLUGIN LOADING
# =============================================================================

test_case "Syntax highlighting plugin is loaded"
if grep -q "fast-syntax-highlighting\|zsh-syntax-highlighting" "$ZSH_DIR/zshrc"; then
  pass
else
  fail "Syntax highlighting plugin should be loaded"
fi

test_case "Autosuggestions plugin is loaded"
if grep -q "zsh-autosuggestions\|autosuggestions" "$ZSH_DIR/zshrc"; then
  pass
else
  fail "Autosuggestions plugin should be loaded"
fi

test_case "zsh-z or similar navigation is loaded"
if grep -q "zsh-z\|z.lua\|autojump\|fasd" "$ZSH_DIR/zshrc"; then
  pass
else
  fail "Directory navigation plugin should be loaded"
fi

# =============================================================================
# ENVIRONMENT VARIABLES
# =============================================================================

test_case "DOTFILES variable is exported"
if grep -q 'export DOTFILES=' "$ZSH_DIR/zshrc"; then
  pass
else
  fail "DOTFILES should be exported"
fi

test_case "EDITOR is configured"
if grep -q 'export EDITOR=' "$ZSH_DIR/zshrc" || grep -q 'EDITOR=' "$ZSH_DIR/zshenv"; then
  pass
else
  fail "EDITOR should be configured"
fi

test_case "Homebrew is configured (macOS)"
if grep -q "brew\|homebrew\|/opt/homebrew" "$ZSH_DIR/zshrc"; then
  pass
else
  skip "Homebrew configuration not found (may not be macOS)"
fi

# =============================================================================
# ALIASES
# =============================================================================

test_case "aliases.zsh defines essential aliases"
essential_aliases=("ls" "ll" "la")
found=0
for alias_name in "${essential_aliases[@]}"; do
  if grep -qE "^alias $alias_name=" "$ZSH_DIR/aliases.zsh"; then
    ((found++))
  fi
done
if [[ $found -ge 2 ]]; then
  pass
else
  fail "Essential ls aliases should be defined"
fi

test_case "Git aliases are defined"
git_aliases=("gs" "ga" "gc" "gp")
found=0
for alias_name in "${git_aliases[@]}"; do
  if grep -qE "^alias $alias_name=" "$ZSH_DIR/aliases.zsh"; then
    ((found++))
  fi
done
if [[ $found -ge 2 ]]; then
  pass
else
  fail "Git aliases should be defined"
fi

# =============================================================================
# ZSHENV CONFIGURATION
# =============================================================================

test_case "zshenv sets PATH correctly"
if grep -q "PATH" "$ZSH_DIR/zshenv"; then
  pass
else
  fail "PATH should be configured in zshenv"
fi

test_case "zshenv is sourced first"
# zshenv should not depend on interactive features
if grep -qE "^compinit|^zinit" "$ZSH_DIR/zshenv"; then
  fail "zshenv should not call compinit or zinit (interactive features)"
else
  pass
fi

# =============================================================================
# PERFORMANCE CONSIDERATIONS
# =============================================================================

test_case "Plugins use turbo mode for lazy loading"
if grep -q "wait\|lucid" "$ZSH_DIR/zshrc"; then
  pass
else
  fail "Plugins should use Zinit's turbo mode (wait/lucid)"
fi

test_case "fpath is set before compinit"
# Check that fpath modification comes before compinit
fpath_line=$(grep -n "fpath=" "$ZSH_DIR/zshrc" 2>/dev/null | head -1 | cut -d: -f1)
compinit_line=$(grep -n "compinit" "$ZSH_DIR/zshrc" 2>/dev/null | head -1 | cut -d: -f1)

if [[ -n "$fpath_line" ]] && [[ -n "$compinit_line" ]]; then
  if [[ "$fpath_line" -lt "$compinit_line" ]]; then
    pass
  else
    fail "fpath should be set before compinit"
  fi
else
  skip "Could not determine order"
fi

# =============================================================================
# STARSHIP PROMPT
# =============================================================================

test_case "Starship prompt is initialized"
if grep -q "starship" "$ZSH_DIR/zshrc"; then
  pass
else
  fail "Starship prompt should be initialized"
fi

# =============================================================================
# THEME INTEGRATION
# =============================================================================

test_case "Theme switcher is sourced"
if grep -q "theme\|current-theme" "$ZSH_DIR/zshrc"; then
  pass
else
  fail "Theme switcher should be integrated"
fi

# =============================================================================
# LIBRARY INTEGRATION
# =============================================================================

test_case "Zsh library modules are available"
lib_dir="$DOTFILES_DIR/src/lib"
if [[ -d "$lib_dir" ]] && [[ -f "$lib_dir/init.zsh" ]]; then
  pass
else
  fail "Library modules should exist at src/lib/"
fi

# =============================================================================
# SPECIAL CHARACTERS AND ENCODING
# =============================================================================

test_case "No BOM or encoding issues in zsh files"
for file in "$ZSH_DIR"/*; do
  if [[ -f "$file" ]]; then
    # Check for BOM (byte order mark)
    if head -c3 "$file" | grep -q $'\xef\xbb\xbf'; then
      fail "BOM found in: $(basename $file)"
    fi
  fi
done
pass

# Cleanup
cleanup_test

exit 0
