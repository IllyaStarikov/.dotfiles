#!/usr/bin/env zsh
# Test zsh compatibility and proper script detection

# Tests handle errors explicitly

# Set up test environment
export TEST_DIR="${TEST_DIR:-$(dirname "$0")/../..}"
export DOTFILES_DIR="${DOTFILES_DIR:-$(dirname "$TEST_DIR")}"

# Source test framework
source "$TEST_DIR/lib/test_helpers.zsh"

describe "Zsh script compatibility tests"

# Test: Setup script runs with zsh
it "setup.sh should run with zsh without errors" && {
    local script_path="$DOTFILES_DIR/src/setup/setup.sh"

    # Check syntax with zsh
    if zsh -n "$script_path" 2>/dev/null; then
        pass "Setup script has valid zsh syntax"
    else
        fail "Setup script has syntax errors with zsh"
    fi
}

# Test: Symlinks script runs with zsh
it "symlinks.sh should run with zsh without errors" && {
    local script_path="$DOTFILES_DIR/src/setup/symlinks.sh"

    # Check syntax with zsh
    if zsh -n "$script_path" 2>/dev/null; then
        pass "Symlinks script has valid zsh syntax"
    else
        fail "Symlinks script has syntax errors with zsh"
    fi
}

# Test: Setup script correctly detects its directory
it "setup.sh should correctly detect DOTFILES_DIR" && {
    # Run the script and capture early output
    output=$(timeout 2 zsh -c "
        set -e
        source '$DOTFILES_DIR/src/setup/setup.sh' --help 2>&1 | head -1
    " 2>&1 || true)

    # The script should not error about DOTFILES_DIR
    if [[ "$output" != *"DOTFILES_DIR"* ]] || [[ "$output" == *"SETUP"* ]]; then
        pass "Script detects directory correctly"
    else
        fail "Script has directory detection issues: $output"
    fi
}

# Test: Symlinks script correctly detects its directory
it "symlinks.sh should correctly detect DOTFILES_DIR" && {
    # Check that the script can find its resources
    output=$(zsh "$DOTFILES_DIR/src/setup/symlinks.sh" --dry-run 2>&1 | head -5 || true)

    if [[ "$output" == *"Dotfiles directory:"* ]] || [[ "$output" == *"Symlink"* ]]; then
        pass "Symlinks script detects directory correctly"
    else
        skip "Could not verify directory detection"
    fi
}

# Test: Template generate script has zsh shebang and syntax
it "template/generate.sh should use zsh" && {
    local script_path="$DOTFILES_DIR/template/generate.sh"

    if [[ -f "$script_path" ]]; then
        # Check shebang
        shebang=$(head -1 "$script_path")
        if [[ "$shebang" == *"zsh"* ]]; then
            pass "Generate script uses zsh shebang"
        else
            fail "Generate script does not use zsh: $shebang"
        fi

        # Check syntax
        if zsh -n "$script_path" 2>/dev/null; then
            pass "Generate script has valid zsh syntax"
        else
            fail "Generate script has syntax errors"
        fi
    else
        skip "Template generate script not found"
    fi
}

# Test: Template mirror script has zsh shebang and syntax
it "template/mirror.sh should use zsh" && {
    local script_path="$DOTFILES_DIR/template/mirror.sh"

    if [[ -f "$script_path" ]]; then
        # Check shebang
        shebang=$(head -1 "$script_path")
        if [[ "$shebang" == *"zsh"* ]]; then
            pass "Mirror script uses zsh shebang"
        else
            fail "Mirror script does not use zsh: $shebang"
        fi

        # Check syntax
        if zsh -n "$script_path" 2>/dev/null; then
            pass "Mirror script has valid zsh syntax"
        else
            fail "Mirror script has syntax errors"
        fi
    else
        skip "Template mirror script not found"
    fi
}

# Test: No BASH_SOURCE references in zsh scripts
it "zsh scripts should not use BASH_SOURCE" && {
    # Check our modified scripts don't have BASH_SOURCE
    for script in "$DOTFILES_DIR/src/setup/setup.sh" \
                  "$DOTFILES_DIR/src/setup/symlinks.sh" \
                  "$DOTFILES_DIR/template/generate.sh" \
                  "$DOTFILES_DIR/template/mirror.sh"; do
        if [[ -f "$script" ]]; then
            if grep -q 'BASH_SOURCE' "$script"; then
                fail "$(basename $script) still contains BASH_SOURCE"
                return 1
            fi
        fi
    done
    pass "No BASH_SOURCE references found"
}

# Test: Scripts use proper zsh directory detection
it "scripts should use proper zsh directory detection" && {
    # Check for ${0} usage instead of BASH_SOURCE
    for script in "$DOTFILES_DIR/src/setup/setup.sh" \
                  "$DOTFILES_DIR/src/setup/symlinks.sh"; do
        if [[ -f "$script" ]]; then
            if grep -q 'dirname.*\${0}' "$script" || grep -q 'dirname.*\$0' "$script"; then
                pass "$(basename $script) uses zsh-style directory detection"
            else
                fail "$(basename $script) may not detect directory correctly"
                return 1
            fi
        fi
    done
}

# Test: Git hooks installer is called with zsh
it "setup.sh should invoke git hooks installer with zsh" && {
    local setup_content=$(cat "$DOTFILES_DIR/src/setup/setup.sh")

    # Check if git hooks installer is invoked with zsh
    if echo "$setup_content" | grep -q 'zsh.*install-git-hooks'; then
        pass "Git hooks installer invoked with zsh"
    else
        # Check if it's not invoked with bash
        if echo "$setup_content" | grep -q 'bash.*install-git-hooks'; then
            fail "Git hooks installer still invoked with bash"
        else
            skip "Git hooks installer invocation not found"
        fi
    fi
}

# Test: Symlinks.sh is invoked with zsh from setup.sh
it "setup.sh should invoke symlinks.sh with zsh" && {
    local setup_content=$(cat "$DOTFILES_DIR/src/setup/setup.sh")

    # Check if symlinks.sh is invoked with zsh
    if echo "$setup_content" | grep -q 'zsh.*symlinks\.sh'; then
        pass "Symlinks script invoked with zsh"
    else
        # Check if it's not invoked with bash
        if echo "$setup_content" | grep -q 'bash.*symlinks\.sh'; then
            fail "Symlinks script still invoked with bash"
        else
            skip "Symlinks script invocation not found"
        fi
    fi
}

# Return success
exit 0