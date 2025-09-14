# Private Repository Test Suite

This document describes how to set up tests in your `.dotfiles.private` repository.

## Directory Structure

Create the following structure in your private repository:

```
.dotfiles.private/
├── test/
│   ├── unit/
│   │   ├── work_config_test.sh
│   │   └── sensitive_settings_test.sh
│   ├── integration/
│   │   ├── work_environment_test.sh
│   │   └── private_tools_test.sh
│   ├── regression/
│   │   └── work_specific_bugs_test.sh
│   └── lib/
│       └── test_helpers.zsh
└── run-tests.sh
```

## Example Test Runner

Create `.dotfiles.private/run-tests.sh`:

```zsh
#!/usr/bin/env zsh
# Private Repository Test Suite

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TEST_DIR="$SCRIPT_DIR/test"
PUBLIC_TEST_LIB="$HOME/.dotfiles/test/lib"

# Source public test helpers
source "$PUBLIC_TEST_LIB/test_helpers.zsh"

# Test size (default: all)
TEST_SIZE="${1:-all}"

echo "Running private repository tests..."

# Run unit tests
if [[ "$TEST_SIZE" == "all" ]] || [[ "$TEST_SIZE" == "unit" ]]; then
    echo "Running unit tests..."
    for test in "$TEST_DIR"/unit/*.sh; do
        [[ -x "$test" ]] && "$test"
    done
fi

# Run integration tests
if [[ "$TEST_SIZE" == "all" ]] || [[ "$TEST_SIZE" == "integration" ]]; then
    echo "Running integration tests..."
    for test in "$TEST_DIR"/integration/*.sh; do
        [[ -x "$test" ]] && "$test"
    done
fi

echo "Private tests completed"
```

## Example Unit Test

Create `.dotfiles.private/test/unit/work_config_test.sh`:

```zsh
#!/usr/bin/env zsh
# Test work-specific configurations

set -euo pipefail

# Use public test helpers
source "$HOME/.dotfiles/test/lib/test_helpers.zsh"

echo -e "${BLUE}=== Work Configuration Tests ===${NC}"

test_case "Work environment detection"
if [[ -f "$HOME/.dotfiles/.dotfiles.private/google/check-google-machine.sh" ]]; then
    output=$("$HOME/.dotfiles/.dotfiles.private/google/check-google-machine.sh")
    if [[ "$output" == "google" ]] || [[ "$output" == "personal" ]]; then
        pass "Environment: $output"
    else
        fail "Unknown environment"
    fi
else
    skip "Work detection script not found"
fi

test_case "Private Neovim modules load"
if [[ -d "$HOME/.dotfiles/.dotfiles.private/neovim" ]]; then
    # Test that private Neovim configs load without errors
    output=$(nvim --headless \
        -c "lua require('private.config')" \
        -c "qa!" 2>&1 || echo "error")

    if [[ "$output" != *"error"* ]]; then
        pass
    else
        fail "Private Neovim config has errors"
    fi
else
    skip "No private Neovim configs"
fi

test_case "Sensitive environment variables are set"
# Check for work-specific environment variables
# DO NOT log actual values!
work_vars=(
    "WORK_PROJECT_ROOT"
    "INTERNAL_TOOLS_PATH"
)

missing=0
for var in "${work_vars[@]}"; do
    if [[ -z "${!var:-}" ]]; then
        ((missing++))
    fi
done

if [[ $missing -eq 0 ]]; then
    pass "All work variables set"
else
    skip "$missing work variables not set"
fi
```

## Integration with Main Test Suite

The main omni-test can detect and run private tests:

```zsh
# In main omni-test, add:
if [[ -d "$HOME/.dotfiles/.dotfiles.private/test" ]]; then
    echo "Running private repository tests..."
    "$HOME/.dotfiles/.dotfiles.private/run-tests.sh" "$TEST_SIZE"
fi
```

## Security Considerations

1. **Never log sensitive data** - Use placeholders or hashes
2. **Sanitize all output** - Remove tokens, keys, internal URLs
3. **Skip tests on public CI** - Check for CI environment variable
4. **Use encryption** - Consider encrypting test data files
5. **Audit regularly** - Review tests for data leaks

## Example Regression Test

Create `.dotfiles.private/test/regression/work_specific_bugs_test.sh`:

```zsh
#!/usr/bin/env zsh
# Regression tests for work-specific bugs

set -euo pipefail

source "$HOME/.dotfiles/test/lib/test_helpers.zsh"

echo -e "${BLUE}=== Work-Specific Regression Tests ===${NC}"

test_case "BUG-12345: LSP crashes with internal proto files"
# Test that the fix for internal proto file handling works
test_proto="$TEST_TMP_DIR/test.proto"
cat > "$test_proto" << 'EOF'
syntax = "proto3";
package test;
message TestMessage {
    string id = 1;
}
EOF

output=$(nvim --headless "$test_proto" \
    -c "lua vim.lsp.start_client({cmd={'clangd'}})" \
    -c "qa!" 2>&1 || echo "crashed")

if [[ "$output" != *"crashed"* ]]; then
    pass
else
    fail "LSP still crashes with proto files"
fi

test_case "BUG-67890: Theme breaks with work terminal"
# Test that theme switching works with internal terminal
if [[ "$TERM_PROGRAM" == "InternalTerm" ]]; then
    "$HOME/.dotfiles/src/theme-switcher/switch-theme.sh" dark >/dev/null 2>&1
    if [[ -f "$HOME/.config/alacritty/theme.toml" ]]; then
        pass
    else
        fail "Theme config not generated for work terminal"
    fi
else
    skip "Not using work terminal"
fi
```

## Running Tests

```bash
# Run all private tests
~/.dotfiles/.dotfiles.private/run-tests.sh

# Run only unit tests
~/.dotfiles/.dotfiles.private/run-tests.sh unit

# Run with debug output
DEBUG=1 ~/.dotfiles/.dotfiles.private/run-tests.sh

# Include in main test suite
~/dotfiles/test/omni-test --large  # Will auto-detect private tests
```

## Best Practices

1. **Keep tests isolated** - Don't depend on main repo tests
2. **Use shared helpers** - Source public test_helpers.zsh
3. **Mock sensitive data** - Never use real credentials
4. **Document well** - Explain what each test validates
5. **Version control** - Track test changes separately
6. **CI/CD integration** - Run on internal CI only