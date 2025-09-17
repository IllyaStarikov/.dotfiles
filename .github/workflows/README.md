# GitHub Actions Workflows

CI/CD pipelines for testing, linting, security, and deployment.

## Workflow Files

- `dependencies.yml` - Weekly dependency updates
- `lint.yml` - Code quality checks
- `pages.yml` - Documentation site deployment
- `release.yml` - Automated releases
- `security.yml` - Secret scanning
- `test.yml` - Test suite execution

## Key Workflows

### Tests (`test.yml`)

Runs on every push/PR across multiple OS:

```yaml
matrix:
  os: [ubuntu-latest, macos-latest, macos-14]
```

- Unit, functional, integration tests
- < 5 minute execution
- Caches dependencies for speed

### Linting (`lint.yml`)

Parallel checks for code quality:

- ShellCheck for shell scripts
- Stylua for Lua
- Ruff for Python
- Markdownlint for docs

### Security (`security.yml`)

Daily scans + every push:

- Gitleaks for secrets
- Dependency vulnerabilities
- SAST analysis

### Pages (`pages.yml`)

Deploys documentation to `dotfiles.starikov.io` on main branch pushes.

## Performance Optimizations

### Caching

```yaml
path: |
  ~/.cache/homebrew
  ~/.npm
  ~/.cache/pip
key: ${{ runner.os }}-${{ hashFiles('**/lockfiles') }}
```

Saves 5 minutes per run.

### Concurrency Control

```yaml
concurrency:
  group: test-${{ github.ref }}
  cancel-in-progress: true
```

Prevents redundant runs.

## Lessons Learned

**Always set timeouts** - Hung jobs consumed 1000+ minutes.

```yaml
timeout-minutes: 20
```

**Matrix testing essential** - Ubuntu passed, macOS failed.

**Cache aggressively** - 70% faster with proper caching.

**Submodules need explicit clone**:

```yaml
with:
  submodules: true
```

## Common Issues

**Homebrew slow**: Set `HOMEBREW_NO_AUTO_UPDATE=1`.

**Wrong directory**: Use `DOTFILES_DIR: ${{ github.workspace }}`.

**Pages deploy fails**: Need write permissions:

```yaml
permissions:
  pages: write
  id-token: write
```

## Monitoring

- Check status: Actions tab in GitHub
- Badges: `![Tests](../../workflows/test/badge.svg)`
- Logs: Click any workflow run

Total CI time reduced from 15 to 5 minutes through optimization.
