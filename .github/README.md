# /.github - GitHub Configuration

> **GitHub-specific settings and automation** - CI/CD pipelines, dependency management, and repository configuration

This directory contains GitHub-specific configuration files that control repository behavior, automated workflows, and integration settings.

## 📁 Directory Structure

```
.github/
├── dependabot.yml     # Automated dependency updates
└── workflows/         # GitHub Actions CI/CD pipelines
    ├── dependencies.yml  # Dependency update automation
    ├── lint.yml         # Code quality checks
    ├── pages.yml        # GitHub Pages deployment
    ├── release.yml      # Release automation
    ├── security.yml     # Security scanning
    └── test.yml         # Test suite execution
```

## 🔧 Configuration Files

### dependabot.yml

Automated dependency updates for:

- **GitHub Actions** - Workflow action versions
- **Submodules** - Private repository updates
- **Package Ecosystems** - npm, pip, bundler

Configuration:

```yaml
version: 2
updates:
  - package-ecosystem: 'github-actions'
    directory: '/'
    schedule:
      interval: 'weekly'
    reviewers:
      - 'IllyaStarikov'
```

## 🚀 GitHub Actions Workflows

### dependencies.yml

**Automated Dependency Management**

- Runs weekly on Mondays at 7 AM UTC
- Updates Homebrew packages
- Updates language package managers
- Creates pull requests for updates

### lint.yml

**Code Quality Enforcement**

- Triggers on push and pull requests
- Runs multiple linters in parallel:
  - ShellCheck for shell scripts
  - Stylua for Lua files
  - Ruff for Python code
  - Markdownlint for documentation
- Fails fast on linting errors

### pages.yml

**GitHub Pages Deployment**

- Builds and deploys documentation site
- Triggers on push to main branch
- Hosts at: `dotfiles.starikov.io`
- Uses Jekyll for static site generation

### release.yml

**Automated Release Creation**

- Triggers on version tags (v*.*.\*)
- Creates GitHub releases
- Generates changelogs
- Attaches relevant artifacts
- Publishes release notes

### security.yml

**Security Scanning**

- Runs on every push and PR
- Gitleaks for secret detection
- Dependency vulnerability scanning
- Security advisories integration
- Blocks PRs with security issues

### test.yml

**Comprehensive Test Suite**

- Multi-OS testing matrix:
  - Ubuntu latest
  - macOS latest
  - macOS 14 (ARM)
- Test levels:
  - Unit tests (< 5s)
  - Functional tests (< 30s)
  - Integration tests (< 60s)
- Parallel execution for speed

## ⚙️ Workflow Features

### Matrix Testing

```yaml
strategy:
  matrix:
    os: [ubuntu-latest, macos-latest, macos-14]
    test-type: [unit, functional, integration]
```

### Caching Strategy

- Homebrew packages
- Node modules
- Python packages
- Build artifacts

### Artifact Management

- Test reports
- Coverage data
- Build outputs
- Performance metrics

## 🔒 Security Features

### Secret Management

- Repository secrets for API keys
- Environment-specific secrets
- Encrypted storage
- Minimal permission scope

### Branch Protection

- Required status checks
- PR reviews required
- No force pushes to main
- Automated security scanning

## 📊 CI/CD Pipeline

### Pipeline Flow

1. **Code Push** → Triggers workflows
2. **Parallel Execution**:
   - Linting checks
   - Security scanning
   - Test execution
3. **Matrix Testing** → Cross-platform validation
4. **Merge Checks** → All must pass
5. **Post-Merge**:
   - Deploy to GitHub Pages
   - Update dependencies
   - Create releases

### Performance Metrics

- Average workflow time: < 5 minutes
- Parallel job execution
- Intelligent caching
- Fast failure detection

## 🎯 Workflow Triggers

### Push Events

- All branches: Run tests and linting
- Main branch: Deploy documentation
- Tag push: Create release

### Pull Request Events

- Run full test suite
- Security scanning
- Code quality checks
- Review requirements

### Scheduled Events

- Weekly dependency updates
- Monthly security audits
- Nightly integration tests

### Manual Dispatch

- On-demand test runs
- Force deployments
- Debug workflows

## 💡 Best Practices

### Workflow Development

1. **Test locally** using `act` tool
2. **Use matrix** for cross-platform testing
3. **Cache aggressively** to improve speed
4. **Fail fast** to save resources
5. **Parallelize** independent jobs

### Security Guidelines

- Never commit secrets
- Use GitHub Secrets for sensitive data
- Enable Dependabot alerts
- Regular security audits
- Minimal permission principle

### Performance Optimization

- Use specific action versions
- Cache dependencies
- Parallelize jobs
- Skip unnecessary steps
- Use conditional execution

## 🐛 Troubleshooting

### Common Issues

**Workflow Failures**

```bash
# Check workflow syntax
yamllint .github/workflows/*.yml

# Test locally with act
act -j test
```

**Cache Problems**

```yaml
# Clear cache by updating key
key: ${{ runner.os }}-cache-v2-${{ hashFiles('**/lockfiles') }}
```

**Permission Errors**

```yaml
# Set proper permissions
permissions:
  contents: read
  pull-requests: write
```

## 📈 Monitoring

### Workflow Insights

- Action run history
- Success/failure rates
- Execution times
- Resource usage

### Alerts

- Failed workflow notifications
- Security alert emails
- Dependabot PR notifications
- Release notifications

## 🔗 Integration Points

### External Services

- GitHub Pages hosting
- Dependabot scanning
- Security advisories
- Release management

### Repository Settings

- Branch protection rules
- Required status checks
- Auto-merge configuration
- Deploy keys

## 📚 Related Documentation

- [Workflows Detail](workflows/README.md)
- [Testing Guide](../test/README.md)
- [Security Policy](../SECURITY.md)
- [GitHub Actions Docs](https://docs.github.com/actions)
- [Main README](../README.md)
