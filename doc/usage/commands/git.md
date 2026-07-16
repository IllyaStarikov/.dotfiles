# Git Commands Quick Reference

> **Quick reference for common Git workflows**

For the complete Git alias reference, see **[Git Reference](../tools/git.md)**.

## Common Workflows

### Feature Branch

```bash
gco main              # Start from main
gpl                   # Update main (git pull)
gcb feature/my-feat   # Create feature branch
# ... make changes ...
gaa                   # Stage all
gcm "feat: add feature" # Commit
gp -u origin HEAD     # Push with upstream
```

### Quick Fix

```bash
gaa && gcm "fix: bug" && gp
```

### Interactive Rebase

```bash
gri HEAD~3            # Rebase last 3 commits
# mark commits to squash/edit
git rebase --continue # Continue after changes
```

### Stash Workflow

```bash
gst push -m "WIP: feature" # Stash with message
gco main              # Switch branches
# ... do other work ...
gco -                 # Back to previous branch
gstp                  # Pop stash
```

## Semantic Commits

Use `gcm` (or `git cm`) with a conventional-commit prefix:

| Prefix      | Example                          | Use for                  |
| ----------- | -------------------------------- | ------------------------ |
| `feat:`     | `gcm "feat: add user auth"`      | New features             |
| `fix:`      | `gcm "fix: null pointer"`        | Bug fixes                |
| `docs:`     | `gcm "docs: update readme"`      | Documentation changes    |
| `refactor:` | `gcm "refactor: extract method"` | Behavior-preserving work |
| `test:`     | `gcm "test: add unit tests"`     | Test additions/changes   |
| `chore:`    | `gcm "chore: update deps"`       | Maintenance tasks        |

## Utility Commands

| Command             | Description                              |
| ------------------- | ---------------------------------------- |
| `git undo` / `gundo` | Undo last commit (keep changes)         |
| `git amend`         | Amend last commit, keep message          |
| `gfresh`            | Update main and delete merged branches   |
| `gwip` / `gunwip`   | Save / restore work-in-progress commit   |
| `gl` / `glo`        | Log: pretty commit graph                 |
| `git shortlog -sn`  | Show author statistics                   |

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
