# /test/sanity - Basic Sanity Checks

## What's in this directory

Sanity tests verify that the basic assumptions about the environment and configuration are true. These are simple checks that should always pass unless something is fundamentally broken.

### Test Categories:
- **Environment checks** - Required tools installed
- **Permission tests** - Files readable/writable
- **Path validation** - Directories exist
- **Dependency checks** - Required versions present
- **Configuration syntax** - Files parse correctly

## Why this exists

Sanity tests catch environmental issues that would cause all other tests to fail mysteriously. They provide clear error messages about what's wrong with the setup rather than cryptic failures deep in complex tests.

## Lessons Learned

### Common Failures
1. **Missing Homebrew** on fresh macOS
2. **Wrong Zsh version** on older systems
3. **No write permissions** in /usr/local
4. **Git not configured** with user.email

### What NOT to Do
- **Don't assume defaults** - Check everything explicitly
- **Don't skip on CI** - CI environments are weird
- **Don't hide failures** - Clear errors save debugging time