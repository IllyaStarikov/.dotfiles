#!/usr/bin/env zsh
# Unit tests for core dotfiles validation
# Tests essential files, configurations, and dependencies

set -euo pipefail

# Source test utilities
source "${TEST_DIR}/lib/test_utils.zsh" 2>/dev/null || {
    echo "FAIL: Could not load test utilities"
    exit 1
}

#######################################
# Test: Essential dotfiles exist
#######################################
test_case "Essential dotfiles exist" test_essential_files() {
    debug_log "Checking for essential dotfiles"

    assert_file_exists "$DOTFILES_DIR/src/neovim/init.lua" "Neovim init.lua exists"
    assert_file_exists "$DOTFILES_DIR/src/zsh/zshrc" "Zsh configuration exists"
    assert_file_exists "$DOTFILES_DIR/src/tmux.conf" "tmux configuration exists"
    assert_file_exists "$DOTFILES_DIR/src/alacritty.toml" "Alacritty configuration exists"
    assert_file_exists "$DOTFILES_DIR/src/git/gitconfig" "Git configuration exists"
    assert_file_exists "$DOTFILES_DIR/src/starship.toml" "Starship configuration exists"
}

#######################################
# Test: Scripts are executable
#######################################
test_case "Scripts have correct permissions" test_script_permissions() {
    debug_log "Checking script permissions"

    local scripts=(
        "$DOTFILES_DIR/src/scripts/update"
        "$DOTFILES_DIR/src/scripts/fixy"
        "$DOTFILES_DIR/src/scripts/scratchpad"
        "$DOTFILES_DIR/src/scripts/fetch-quotes"
        "$DOTFILES_DIR/src/scripts/bugreport"
        "$DOTFILES_DIR/src/theme-switcher/switch-theme.sh"
        "$DOTFILES_DIR/test/run"
    )

    for script in "${scripts[@]}"; do
        if [[ -f "$script" ]]; then
            assert_true "[[ -x '$script' ]]" "$(basename "$script") is executable"
        else
            debug_log "Skipping non-existent script: $script"
        fi
    done
}

#######################################
# Test: No syntax errors in shell scripts
#######################################
test_case "Shell scripts have valid syntax" test_shell_syntax() {
    debug_log "Validating shell script syntax"

    local error_count=0
    local checked_count=0

    # Check all shell scripts
    while IFS= read -r -d '' script; do
        ((checked_count++))
        local script_name=$(basename "$script")

        debug_log "Checking syntax: $script_name"

        if ! zsh -n "$script" 2>/dev/null; then
            error_log "Syntax error in $script_name"
            ((error_count++))
        fi
    done < <(find "$DOTFILES_DIR/src" "$DOTFILES_DIR/test" -name "*.sh" -o -name "*.zsh" -type f -print0 2>/dev/null)

    info_log "Checked $checked_count scripts, found $error_count errors"
    assert_equals 0 "$error_count" "No syntax errors in shell scripts"
}

#######################################
# Test: Required commands are available
#######################################
test_case "Required commands are installed" test_required_commands() {
    debug_log "Checking for required commands"

    # Core requirements
    assert_command_exists "git" "Git is installed"
    assert_command_exists "zsh" "Zsh is installed"
    assert_command_exists "curl" "curl is installed"

    # Optional but recommended tools
    if [[ "$(uname)" == "Darwin" ]]; then
        assert_command_exists "brew" "Homebrew is installed (macOS)"
    fi

    # Development tools (warn if missing)
    for cmd in nvim tmux node python3; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            warn_log "Optional command not found: $cmd"
        else
            debug_log "Found optional command: $cmd"
        fi
    done
}

#######################################
# Test: Configuration files are valid
#######################################
test_case "Configuration files are valid" test_config_validity() {
    debug_log "Validating configuration files"

    # Test TOML files
    local toml_files=(
        "$DOTFILES_DIR/src/alacritty.toml"
        "$DOTFILES_DIR/src/starship.toml"
    )

    for toml in "${toml_files[@]}"; do
        if [[ -f "$toml" ]]; then
            # Basic TOML validation (check for common errors)
            if grep -q '^\[.*\[' "$toml"; then
                error_log "Potential TOML syntax error in $(basename "$toml"): unclosed section"
                return 1
            fi
            debug_log "$(basename "$toml") appears valid"
        fi
    done

    # Test JSON files
    if [[ -f "$DOTFILES_DIR/config/fixy.json" ]]; then
        if command -v jq >/dev/null 2>&1; then
            if ! jq empty "$DOTFILES_DIR/config/fixy.json" 2>/dev/null; then
                error_log "Invalid JSON in fixy.json"
                return 1
            fi
            debug_log "fixy.json is valid JSON"
        else
            debug_log "jq not available, skipping JSON validation"
        fi
    fi
}

#######################################
# Test: Directory structure is correct
#######################################
test_case "Directory structure is correct" test_directory_structure() {
    debug_log "Checking directory structure"

    local required_dirs=(
        "$DOTFILES_DIR/src"
        "$DOTFILES_DIR/src/neovim"
        "$DOTFILES_DIR/src/zsh"
        "$DOTFILES_DIR/src/scripts"
        "$DOTFILES_DIR/src/git"
        "$DOTFILES_DIR/src/theme-switcher"
        "$DOTFILES_DIR/test"
        "$DOTFILES_DIR/test/unit"
        "$DOTFILES_DIR/test/lib"
    )

    for dir in "${required_dirs[@]}"; do
        assert_dir_exists "$dir" "Directory exists: $(basename "$dir")"
    done
}

#######################################
# Test: Git repository is clean
#######################################
test_case "Git repository status" test_git_status() {
    debug_log "Checking git repository status"

    cd "$DOTFILES_DIR"

    # Check if it's a git repository
    assert_true "[[ -d .git ]]" "Dotfiles is a git repository"

    # Get status information
    local branch=$(git branch --show-current 2>/dev/null || echo "unknown")
    local uncommitted=$(git status --porcelain 2>/dev/null | wc -l)

    info_log "Current branch: $branch"
    info_log "Uncommitted changes: $uncommitted files"

    # Warning if there are many uncommitted changes
    if [[ $uncommitted -gt 10 ]]; then
        warn_log "Many uncommitted changes detected ($uncommitted files)"
    fi
}

#######################################
# Test: Performance benchmarks
#######################################
test_case "Performance benchmarks" test_performance() {
    debug_log "Running performance benchmarks"

    # Test shell startup time
    benchmark "Zsh startup" 500 zsh -i -c exit

    # Test script execution time
    if [[ -x "$DOTFILES_DIR/src/theme-switcher/switch-theme.sh" ]]; then
        benchmark "Theme switcher" 1000 "$DOTFILES_DIR/src/theme-switcher/switch-theme.sh" --help
    fi

    # Test Neovim startup (if available)
    if command -v nvim >/dev/null 2>&1; then
        benchmark "Neovim startup" 500 nvim --headless -c qa
    fi
}

#######################################
# Test: Environment variables
#######################################
test_case "Environment variables are set" test_environment() {
    debug_log "Checking environment variables"

    # Check critical environment variables
    assert_true "[[ -n '$HOME' ]]" "HOME is set"
    assert_true "[[ -n '$PATH' ]]" "PATH is set"
    assert_true "[[ -n '$SHELL' ]]" "SHELL is set"

    # Check dotfiles-specific variables
    if [[ -n "$DOTFILES_DIR" ]]; then
        assert_equals "$DOTFILES_DIR" "$(cd "$(dirname "$TEST_DIR")" && pwd)" "DOTFILES_DIR is correct"
    fi

    # Check PATH contains expected directories
    assert_contains "$PATH" "/usr/local/bin" "PATH contains /usr/local/bin"

    if [[ -d "$HOME/.local/bin" ]]; then
        debug_log "Checking if PATH contains ~/.local/bin"
        assert_contains "$PATH" "$HOME/.local/bin" "PATH contains ~/.local/bin"
    fi
}

#######################################
# Test: Symlinks are valid
#######################################
test_case "Symlinks point to correct locations" test_symlinks() {
    debug_log "Checking symlink validity"

    local broken_links=0
    local valid_links=0

    # Common symlink locations
    local symlinks=(
        "$HOME/.zshrc"
        "$HOME/.config/nvim"
        "$HOME/.tmux.conf"
        "$HOME/.gitconfig"
    )

    for link in "${symlinks[@]}"; do
        if [[ -L "$link" ]]; then
            if [[ -e "$link" ]]; then
                valid_links=$((valid_links + 1))
                debug_log "Valid symlink: $link -> $(readlink "$link")"
            else
                broken_links=$((broken_links + 1))
                error_log "Broken symlink: $link -> $(readlink "$link")"
            fi
        else
            debug_log "Not a symlink or doesn't exist: $link"
        fi
    done

    info_log "Found $valid_links valid symlinks, $broken_links broken"
    assert_equals 0 "$broken_links" "No broken symlinks"
}

#######################################
# Main execution
#######################################
main() {
    info_log "Starting unit tests for core validation"
    info_log "Test directory: $TEST_DIR"
    info_log "Dotfiles directory: $DOTFILES_DIR"

    # Run all test functions
    test_essential_files
    test_script_permissions
    test_shell_syntax
    test_required_commands
    test_config_validity
    test_directory_structure
    test_git_status
    test_performance
    test_environment
    test_symlinks

    info_log "Unit tests completed"
}

# Run tests
main "$@"
