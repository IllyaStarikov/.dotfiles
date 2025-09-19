# Integration Tests

Tests interactions between multiple components to ensure they work together correctly.

## Test Files

- `dotfiles_sync_test.sh` - Repository synchronization
- `keybinding_conflicts.zsh` - Key mapping conflicts
- `scripts_functionality.zsh` - Script interactions
- `setup_workflow_test.sh` - Installation workflow
- `theme_switching_test.sh` - Cross-app theme sync

## Running Tests

```bash
./test/runner.zsh --integration           # All integration tests
./test/integration/setup_workflow_test.sh  # Specific test
TEST_DEBUG=1 ./test/runner.zsh integration/      # With debugging
```

## What We Test

### Setup Workflow

- Fresh installation completes successfully
- Symlinks don't overwrite existing files
- Dependencies install in correct order

### Theme Switching

- All 5 apps update atomically
- No tmux session crashes
- Lock file prevents race conditions

### Keybinding Conflicts

- No overlapping shortcuts between:
  - Neovim leader mappings
  - Tmux prefix combinations
  - Zsh vi mode bindings
  - Terminal app shortcuts

### Script Interactions

- Scripts can call each other
- Shared functions work
- PATH resolution correct

## Key Lessons

### Environment Isolation

Always use `TEST_HOME` to avoid modifying real user files:

```bash
TEST_HOME="$TEST_TMP_DIR/home"
export HOME="$TEST_HOME"
```

### Timing Issues

Theme switching needs proper synchronization:

```bash
# Wait for config files to be written
while [[ ! -f "$config_file" ]]; do
    sleep 0.1
done
```

### Common Failures

- **Setup order matters** - Brew must install before language tools
- **Symlink races** - Multiple setup.sh runs can corrupt links
- **Theme lock timeout** - 5 seconds too short for slow systems
- **Keybinding shadowing** - Plugin mappings override core mappings

## Debug Tips

```bash
# Run with verbose output
TEST_DEBUG=1 ./test/integration/test.sh

# Keep test environment for inspection
NO_CLEANUP=1 ./test/integration/test.sh

# Test in Docker for clean environment
docker run -it dotfiles:test
```

Integration tests have caught 50+ multi-component bugs before production.
