# Git Commands Quick Reference

> **Quick reference for common Git workflows**

For the complete Git alias reference, see **[Git Reference](../tools/git.md)**.

## Common Workflows

### Feature Branch

```bash
gco main              # Start from main
gl                    # Update main
gcb feature/my-feat   # Create feature branch
# ... make changes ...
gaa                   # Stage all
gcmsg "feat: add feature" # Commit
gpsup                 # Push with upstream
```

### Quick Fix

```bash
gaa && gcmsg "fix: bug" && gp
# or
git fix "bug description"
```

### Interactive Rebase

```bash
grbi HEAD~3           # Rebase last 3 commits
# mark commits to squash/edit
grbc                  # Continue after changes
```

### Stash Workflow

```bash
gsta -m "WIP: feature" # Stash with message
gco main              # Switch branches
# ... do other work ...
gco -                 # Back to previous branch
gstp                  # Pop stash
```

## Semantic Commits

| Command        | Example                         | Result                     |
| -------------- | ------------------------------- | -------------------------- |
| `git feat`     | `git feat "add user auth"`      | `feat: add user auth`      |
| `git fix`      | `git fix "null pointer"`        | `fix: null pointer`        |
| `git docs`     | `git docs "update readme"`      | `docs: update readme`      |
| `git refactor` | `git refactor "extract method"` | `refactor: extract method` |
| `git test`     | `git test "add unit tests"`     | `test: add unit tests`     |
| `git chore`    | `git chore "update deps"`       | `chore: update deps`       |

## Utility Commands

| Command        | Description                     |
| -------------- | ------------------------------- |
| `git undo`     | Undo last commit (keep changes) |
| `git cleanup`  | Delete merged branches          |
| `git standup`  | Show commits since yesterday    |
| `git who`      | Show author statistics          |

## GitHub CLI

| Command           | Description         |
| ----------------- | ------------------- |
| `gh pr create`    | Create pull request |
| `gh pr list`      | List PRs            |
| `gh pr checkout`  | Checkout PR locally |
| `gh pr merge`     | Merge PR            |
| `gh issue create` | Create issue        |
| `gh repo clone`   | Clone repository    |

---

<p align="center">
  <a href="../README.md">← Back to Usage</a>
</p>
