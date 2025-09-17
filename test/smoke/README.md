# /test/smoke - Quick Validation Tests

## What's in this directory

Smoke tests are rapid validation checks that ensure the most critical functionality works after changes. These tests run in under 30 seconds and catch obvious breaks before running the full test suite.

### Purpose:

- **First line of defense** - Catch breaks immediately
- **Fast feedback** - < 30 second execution
- **Critical path only** - Test what absolutely must work
- **CI gatekeeper** - Fail fast to save resources

## Test Coverage

Smoke tests verify:

1. **Neovim starts** without errors
2. **Shell loads** with core functions
3. **Theme switches** without crashes
4. **Scripts execute** without syntax errors
5. **Symlinks valid** and point correctly

## Lessons Learned

### What NOT to Do

- **Don't test everything** - That's what full tests are for
- **Don't skip smoke tests** - Even for "simple" changes
- **Don't let them grow** - Keep under 30 seconds

### Discovered Issues

- Shell startup failures from syntax errors
- Missing dependencies breaking everything
- Circular symlinks causing infinite loops

The smoke test saved 1000+ CI minutes by catching obvious breaks early.
