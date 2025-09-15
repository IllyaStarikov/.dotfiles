# /test/security - Security & Vulnerability Tests

## What's in this directory

Security tests scan for vulnerabilities, exposed secrets, insecure configurations, and potential attack vectors in the dotfiles configuration.

### Test Coverage:
- **Secret scanning** - API keys, passwords, tokens
- **Permission audits** - World-writable files
- **Dependency vulnerabilities** - Known CVEs
- **Shell injection** - Command injection risks
- **Path traversal** - Directory escape attempts

## Why this exists

Dotfiles are often public repositories, making security critical. These tests prevent accidentally committing secrets or creating vulnerabilities that could be exploited.

## Lessons Learned

### Secrets Found & Fixed
1. **AWS keys in gitconfig** - Moved to environment
2. **NPM token in .npmrc** - Now uses keychain
3. **Database URL in alias** - Moved to private repo
4. **SSH key in script** - Changed to ssh-agent

### What NOT to Do
- **Don't commit .env files** - Even "example" ones
- **Don't hardcode passwords** - Use password managers
- **Don't trust user input** - Always sanitize in scripts
- **Don't skip Gitleaks** - It catches real problems

### Security Improvements
- All secrets now in `.dotfiles.private/`
- Pre-commit hooks run Gitleaks
- CI runs security scan on every push
- Sensitive aliases load conditionally