# Code Review Workflow

> **Effective pull request and review process**

## As a Reviewer

### 1. Finding PRs to Review

```bash
# List all open PRs
gh pr list

# List PRs requesting your review
gh pr list --search "review-requested:@me"

# List PRs by label
gh pr list --label "needs-review"

# View PR in browser
gh pr view 123 --web
```

### 2. Checking Out PR Locally

```bash
# Fetch and checkout PR
gh pr checkout 123

# Alternative method
git fetch origin pull/123/head:pr-123
gco pr-123

# View changes
gd main...HEAD  # All changes
gds             # If any staged
gl --oneline main..HEAD  # Commits
```

### 3. Running Local Tests

```bash
# Install dependencies
npm install
pip install -r requirements.txt

# Run tests
npm test
pytest

# Run specific tests related to changes
npm test auth
pytest tests/test_auth.py

# Check coverage
npm run test:coverage
```

### 4. Code Quality Checks

```bash
# Linting
npm run lint
ruff check .

# Type checking
npm run typecheck
mypy .

# Security scan
npm audit
bandit -r src/

# Performance
npm run build
npm run analyze
```

### 5. Manual Testing

```bash
# Start development server
npm run dev

# Test specific flows
# 1. Happy path
# 2. Error scenarios
# 3. Edge cases
# 4. Backwards compatibility

# API testing
http GET localhost:3000/api/users
http POST localhost:3000/api/auth/login \
  email=test@example.com \
  password=test123
```

### 6. Review in Editor

```vim
" In Neovim
:DiffviewOpen main...HEAD  " View all changes
:Gdiffsplit main:path/to/file  " Compare with main

" Navigate changes
]c  " Next change
[c  " Previous change

" Comment on code
<leader>gc  " GitHub comment (with plugin)
```

### 7. Leaving Review Comments

#### Via GitHub CLI

```bash
# Approve
gh pr review 123 --approve --body "LGTM! Nice work."

# Request changes
gh pr review 123 --request-changes \
  --body "Please address the security concern in auth.py"

# Comment only
gh pr review 123 --comment \
  --body "Looking good, just a few suggestions"
```

#### Review Comment Best Practices

````markdown
## Effective Comment

```suggestion
# More efficient approach
users = User.objects.filter(active=True).select_related('profile')
```
````

This avoids N+1 queries by using `select_related`.

## Clear Feedback

**Issue**: This could cause a memory leak in production.

**Suggestion**: Consider using a context manager:

```python
with open(file_path) as f:
    data = f.read()
```

## Actionable Request

Could we add error handling here? For example:

```python
try:
    result = external_api_call()
except RequestException as e:
    logger.error(f"API call failed: {e}")
    return None
```

````

### 8. Review Checklist

```markdown
## Code Quality
- [ ] Code follows project style guide
- [ ] No unnecessary complexity
- [ ] DRY principles followed
- [ ] Clear variable/function names

## Functionality
- [ ] Changes match PR description
- [ ] Edge cases handled
- [ ] Error handling appropriate
- [ ] No regressions introduced

## Testing
- [ ] Tests cover new functionality
- [ ] Tests are meaningful
- [ ] Coverage maintained/improved
- [ ] Tests follow testing standards

## Security
- [ ] No hardcoded secrets
- [ ] Input validation present
- [ ] SQL injection prevented
- [ ] XSS vulnerabilities addressed

## Performance
- [ ] No N+1 queries
- [ ] Efficient algorithms used
- [ ] Caching considered
- [ ] Database indexes appropriate

## Documentation
- [ ] Code is self-documenting
- [ ] Complex logic explained
- [ ] API changes documented
- [ ] README updated if needed
````

## As a PR Author

### 9. Creating Effective PRs

```bash
# Create PR with template
gh pr create --fill

# Or with custom details
gh pr create \
  --title "feat: Add user authentication" \
  --body "$(cat .github/pull_request_template.md)" \
  --assignee "@me" \
  --reviewer teamlead \
  --label enhancement \
  --milestone v1.2.0
```

#### PR Description Template

```markdown
## Description

Brief description of changes and why they're needed.

## Type of Change

- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Changes Made

- Implemented OAuth2 authentication
- Added user session management
- Created auth middleware

## Testing

- [ ] Unit tests added/updated
- [ ] Integration tests added/updated
- [ ] Manual testing completed

## Screenshots

[If applicable]

## Related Issues

Closes #123
```

### 10. Preparing for Review

```bash
# Self-review first
gd main...HEAD | less
gh pr diff 123

# Run all checks locally
npm run precommit
make lint test

# Check PR status
gh pr checks 123
gh pr view 123
```

### 11. Responding to Feedback

```bash
# View review comments
gh pr view 123 --comments

# Make requested changes
v src/auth.py
# ... make changes ...

# Commit with clear message
gaa
gcmsg "fix: address review feedback

- Add error handling for API calls
- Improve query performance
- Add missing tests"

# Push changes
gp
```

### 12. Re-requesting Review

```bash
# After addressing feedback
gh pr review 123 --comment \
  --body "Thanks for the review! I've addressed all feedback:
  - Added error handling
  - Optimized queries
  - Improved test coverage

  Please take another look."

# Re-request review
gh pr ready 123
```

## Review Communication

### Effective Patterns

#### As Reviewer

```markdown
# Positive reinforcement

"Great use of the strategy pattern here! 👍"

# Constructive criticism

"This works, but have you considered using a Set
for O(1) lookups instead of Array.includes()?"

# Blocking issue

"🚨 This will break production - the API expects
camelCase but we're sending snake_case."
```

#### As Author

```markdown
# Acknowledging feedback

"Good catch! I've updated this in commit abc123"

# Explaining decisions

"I considered that approach but went with this because
it maintains consistency with our existing patterns"

# Asking for clarification

"I'm not sure I understand - could you provide an
example of what you mean?"
```

## Advanced Review Techniques

### 13. Batch Reviews

```bash
# Review multiple PRs efficiently
for pr in $(gh pr list --limit 10 --json number -q '.[].number'); do
  echo "Reviewing PR #$pr"
  gh pr checkout $pr
  npm test
  gh pr diff $pr
done
```

### 14. Automated Checks

```yaml
# .github/workflows/pr-check.yml
name: PR Checks
on: pull_request

jobs:
  quality:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - run: npm ci
      - run: npm run lint
      - run: npm test
      - run: npm run build
```

### 15. Review Tools Integration

```vim
" Neovim plugins for review
Plug 'pwntester/octo.nvim'  " GitHub integration
Plug 'sindrets/diffview.nvim'  " Better diffs

" Usage
:Octo pr list
:Octo pr checkout 123
:Octo review start
```

## Quick Reference

### Common Commands

```bash
# List and checkout
gh pr list
gh pr checkout 123

# Review
gh pr diff 123
gh pr review 123 --approve
gh pr review 123 --request-changes

# Comment
gh pr comment 123 --body "message"

# Merge
gh pr merge 123 --squash
```

### Review Etiquette

1. **Be constructive** - Suggest improvements, don't just criticize
2. **Be specific** - Point to exact lines and provide examples
3. **Be timely** - Review within 24 hours if possible
4. **Be thorough** - But also pragmatic
5. **Be kind** - Remember there's a person on the other side

---

<p align="center">
  <a href="README.md">← Back to Workflows</a>
</p>
