# End-to-End Test Suite

Comprehensive E2E testing for the dotfiles repository that validates the complete setup process across multiple platforms.

## Overview

The E2E test suite ensures that:

- The setup script runs successfully on all supported platforms
- All symlinks are created correctly
- Core tools are installed and configured
- Unit and functional tests pass in a clean environment
- The development environment is fully functional after setup

## Test Coverage

### Platforms Tested

- **Ubuntu 22.04 LTS** - Primary Debian-based distribution
- **Fedora 39** - RPM-based distribution
- **Arch Linux** - Rolling release distribution
- **macOS** - Latest and previous versions (in CI)

### Test Phases

1. **Environment Preparation**
   - Set execute permissions on scripts
   - Create required directories
   - Validate dotfiles structure

2. **Setup Script Execution**
   - Run `setup.sh` with appropriate flags
   - Handle platform-specific installations
   - Create all symlinks

3. **Installation Verification**
   - Check core tools (git, zsh, tmux, nvim)
   - Verify development tools (python, node, etc.)
   - Validate optional tools (ripgrep, fd, fzf)

4. **Configuration Verification**
   - Verify all symlinks point to correct targets
   - Test shell configuration loads without errors
   - Validate Neovim starts successfully

5. **Test Suite Execution**
   - Run unit tests
   - Run functional tests
   - Run integration tests (where applicable)

## Running E2E Tests

### Local Docker Testing

Run tests for all Linux distributions:

```bash
./test/e2e/runner.zsh
```

Test specific platform:

```bash
# Ubuntu only
./test/e2e/runner.zsh --linux
docker-compose -f test/e2e/docker-compose.yml up ubuntu-e2e

# With debugging
./test/e2e/runner.zsh --verbose --keep-container
```

### macOS Testing

Run on macOS host:

```bash
./test/e2e/runner.zsh --macos
```

### Docker Compose

Test all platforms in parallel:

```bash
cd test/e2e
docker-compose up --abort-on-container-exit
```

Interactive debugging:

```bash
docker-compose -f test/e2e/docker-compose.yml run debug-e2e
```

## CI/CD Integration

The E2E tests run automatically on:

- Every push to main branch
- All pull requests
- Nightly schedule (2 AM UTC)
- Manual workflow dispatch

### GitHub Actions Workflow

The workflow tests on:

- Ubuntu (Docker)
- Fedora (Docker)
- Arch (Docker)
- macOS latest
- macOS 14

View workflow: `.github/workflows/e2e.yml`

## Test Results

### Success Criteria

All tests must pass:

- ✅ Setup script completes without errors
- ✅ All required tools installed
- ✅ All symlinks created correctly
- ✅ Shell configuration loads
- ✅ Neovim starts without errors
- ✅ Unit tests pass
- ✅ Functional tests pass (or gracefully skip in CI)

### Logs and Artifacts

Test logs are saved to:

- Local: `test/logs/e2e_<timestamp>/`
- CI: Available as workflow artifacts

Each test run generates:

- `main.log` - Overall test execution
- `<platform>.log` - Platform-specific results
- `report.md` - Summary report

## Troubleshooting

### Common Issues

**Docker build fails**

```bash
# Clean Docker cache
docker system prune -a
docker volume prune

# Rebuild without cache
docker-compose build --no-cache
```

**Tests fail in container but pass locally**

- Check for hardcoded paths
- Verify CI environment variables
- Review permission issues

**Symlinks not created**

- Ensure setup script has execute permissions
- Check `$HOME` variable in container
- Verify source files exist

### Debugging

Enter debug container:

```bash
docker-compose -f test/e2e/docker-compose.yml run debug-e2e

# Inside container
cd /home/testuser/.dotfiles
./src/setup/setup.sh --verbose
```

Run specific test phase:

```bash
docker run --rm -it \
  -v $(pwd):/home/testuser/.dotfiles:ro \
  dotfiles-e2e:ubuntu \
  bash -c "cd /home/testuser/.dotfiles && ./test/e2e/run_e2e_test.sh"
```

## Development

### Adding New Platform

1. Create Dockerfile:

```dockerfile
# test/e2e/Dockerfile.newplatform
FROM newplatform:latest
# ... setup
```

2. Add to docker-compose.yml:

```yaml
newplatform-e2e:
  build:
    dockerfile: test/e2e/Dockerfile.newplatform
  # ... configuration
```

3. Update CI workflow:

```yaml
matrix:
  distro: [ubuntu, fedora, arch, newplatform]
```

### Extending Test Coverage

Add test phases to `run_e2e_test.sh`:

```bash
phase_custom_test() {
  print_info "Running custom test..."
  # Test implementation
  return 0
}

# In main()
run_phase "Custom Test" phase_custom_test
```

## Performance

Typical execution times:

- Ubuntu E2E: ~3-5 minutes
- Fedora E2E: ~3-5 minutes
- Arch E2E: ~3-5 minutes
- macOS E2E: ~2-3 minutes (symlinks only)
- Full suite: ~10-15 minutes (parallel)

## Security Considerations

- Tests run in isolated containers
- No sensitive data in test environments
- Read-only mount of dotfiles in containers
- Temporary directories cleaned after tests

## Contributing

When adding new features:

1. Ensure E2E tests still pass
2. Add verification for new functionality
3. Update this README if needed
4. Test on at least Ubuntu and macOS

## Related Documentation

- [Main Test README](../README.md)
- [Setup Script](../../src/setup/README.md)
- [CI/CD Documentation](../../.github/workflows/README.md)
