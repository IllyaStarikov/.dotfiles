# Feature Development Workflow

> **From idea to deployment - complete feature lifecycle**

## Planning Phase

### 1. Define Feature

```bash
# Check existing issues
gh issue list
gh issue view 123

# Create feature issue
gh issue create --title "Add user authentication" \
  --body "Implement OAuth2 with GitHub and other providers"

# Or use web interface
gh issue create --web
```

### 2. Design Approach

```bash
# Create design doc
mkdir -p docs/design
v docs/design/auth-system.md

# Research existing code
rg -t py "auth|login|user" --stats
fd -e py auth | xargs bat

# Check dependencies
cat requirements.txt | grep -i auth
```

## Implementation Phase

### 3. Setup Branch

```bash
# Ensure main is current
gco main
gl

# Create feature branch
# Format: feature/issue-number-description
gcb feature/123-user-auth
# or semantic
git feat user-authentication

# Set upstream
gpsup
```

### 4. Development Environment

```bash
# Install dependencies
pip install -r requirements.txt
npm install

# Setup environment
cp .env.example .env
v .env  # Configure

# Run in development
npm run dev
# or
python manage.py runserver
```

### 5. Write Code

#### Project Navigation

```bash
# In Neovim
<leader>ff    # Find files
<leader>fg    # Search project
<leader>fb    # Browse buffers
<leader>e     # File explorer
```

#### Code Intelligence

```vim
" Navigation
gd            " Go to definition
gr            " Find references
gi            " Go to implementation
K             " Show documentation

" Refactoring
<leader>rn    " Rename symbol
<leader>ca    " Code actions
```

#### AI Assistance

```vim
" Get help
<leader>cc    " Open AI chat
<leader>ca    " Show AI actions

" With selection
<leader>co    " Optimize code
<leader>cf    " Fix issues
<leader>ce    " Explain code
```

### 6. Test Driven Development

```bash
# Write test first
v tests/test_auth.py

# Run tests continuously
npm run test:watch
# or
pytest-watch

# Run specific test
pytest tests/test_auth.py::test_login
npm test -- --grep "login"
```

### 7. Code Quality

#### Linting and Formatting

```bash
# Format code
black .
prettier --write .
<leader>f     # In Neovim

# Lint
ruff check .
eslint .

# Type check
mypy .
tsc --noEmit
```

#### Code Review Self-Check

```bash
# Review your changes
gd            # git diff
gds           # staged diff

# Check specific file
gd auth.py

# Visual review
lazygit       # Interactive UI
<leader>gg    # In Neovim
```

## Testing Phase

### 8. Unit Tests

```bash
# Run all tests
npm test
pytest

# Coverage report
npm run test:coverage
pytest --cov=src --cov-report=html

# Open coverage
open htmlcov/index.html
```

### 9. Integration Tests

```bash
# API tests
http POST localhost:8000/api/auth/login \
  email=test@example.com \
  password=secret

# E2E tests
npm run test:e2e
playwright test
```

### 10. Manual Testing

```bash
# Test in browser
npm run dev
open http://localhost:3000

# Test different scenarios
# - Happy path
# - Error cases
# - Edge cases
# - Performance
```

## Documentation Phase

### 11. Code Documentation

```python
# Docstrings
def authenticate(email: str, password: str) -> User:
    """
    Authenticate user with email and password.

    Args:
        email: User's email address
        password: Plain text password

    Returns:
        User object if authenticated

    Raises:
        AuthenticationError: If credentials invalid
    """
```

```bash
# Generate docs
npm run docs:build
sphinx-build docs docs/_build
```

### 12. User Documentation

```bash
# Update README
v README.md

# Add examples
mkdir -p examples
v examples/auth_example.py

# Update changelog
v CHANGELOG.md
```

## Review Phase

### 13. Pre-Commit Checks

```bash
# Run all checks
npm run precommit
# or manual
black . && ruff check . && pytest && npm test

# Fix issues
ruff check --fix .
```

### 14. Commit Work

```bash
# Stage changes
ga .
# or selective
ga src/auth/
git add -p  # Interactive

# Commit with conventional message
gcmsg "feat(auth): implement OAuth2 authentication

- Add GitHub and other OAuth providers
- Implement JWT token generation
- Add user session management

Closes #123"
```

### 15. Push and Create PR

```bash
# Push branch
gp
# or first time
gpsup

# Create pull request
gh pr create \
  --title "feat: Add OAuth2 authentication" \
  --body "$(cat .github/pull_request_template.md)" \
  --assignee @me \
  --label enhancement

# Or interactive
gh pr create --web
```

## Code Review Phase

### 16. Respond to Review

```bash
# Check PR status
gh pr status
gh pr checks

# View comments
gh pr view 124 --comments

# Make changes
v src/auth/oauth.py
# Fix issues...

# Commit fixes
gaa
gcmsg "fix: address review comments"
gp
```

### 17. Update PR

```bash
# Rebase on main
gco main
gl
gco -
grb main

# Or merge main
gm main

# Force push if needed
gpf
```

## Deployment Phase

### 18. Merge PR

```bash
# Squash and merge
gh pr merge 124 --squash --delete-branch

# Or via web
gh pr view --web
```

### 19. Deploy

```bash
# Deploy to staging
npm run deploy:staging
# or
git push staging main

# Run smoke tests
npm run test:staging

# Deploy to production
npm run deploy:prod
# or
git push production main
```

### 20. Monitor

```bash
# Check deployment
curl https://api.example.com/health

# Watch logs
npm run logs:prod
# or
heroku logs --tail

# Monitor metrics
open https://dashboard.example.com
```

## Post-Release

### 21. Cleanup

```bash
# Delete local branch
gco main
gb -d feature/123-user-auth

# Prune remote branches
git remote prune origin

# Update local
gl
```

### 22. Document Release

```bash
# Update changelog
v CHANGELOG.md

# Tag release
git tag -a v1.2.0 -m "Release version 1.2.0"
git push --tags

# Create release
gh release create v1.2.0 \
  --title "v1.2.0 - OAuth Authentication" \
  --notes "$(cat CHANGELOG.md | sed -n '/## 1.2.0/,/## 1.1.0/p')"
```

## Feature Workflow Checklist

```markdown
## Pre-Development

- [ ] Issue created and assigned
- [ ] Design documented
- [ ] Dependencies identified
- [ ] Branch created from main

## Development

- [ ] Tests written first (TDD)
- [ ] Implementation complete
- [ ] All tests passing
- [ ] Code formatted and linted
- [ ] Documentation updated

## Review

- [ ] Self-review completed
- [ ] PR created with description
- [ ] CI checks passing
- [ ] Code review approved
- [ ] Branch up to date with main

## Deployment

- [ ] Merged to main
- [ ] Deployed to staging
- [ ] Smoke tests passed
- [ ] Deployed to production
- [ ] Monitoring confirmed

## Post-Release

- [ ] Branch cleaned up
- [ ] Release documented
- [ ] Stakeholders notified
```

## Quick Commands Summary

```bash
# Start feature
gco main && gl && gcb feature/name

# During development
<leader>ff    # Find files
gd            # Check changes
npm test      # Run tests

# Commit and push
gaa && gcmsg "feat: description" && gp

# Create PR
gh pr create --web

# After merge
gco main && gl && gb -d feature/name
```

---

<p align="center">
  <a href="README.md">← Back to Workflows</a>
</p>
