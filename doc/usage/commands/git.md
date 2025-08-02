# Git Commands Reference

> **Quick reference for Git aliases and workflows**

## Essential Aliases

### Status & Information

| Command | Full Command | Description |
|---------|--------------|-------------|
| `gs` | `git status` | Show working tree status |
| `gst` | `git status -s` | Short status format |
| `gss` | `git status -s` | Short status format |
| `gsb` | `git status -sb` | Short with branch info |

### Staging & Committing

| Command | Full Command | Description |
|---------|--------------|-------------|
| `ga` | `git add` | Stage files |
| `gaa` | `git add --all` | Stage all changes |
| `gapa` | `git add --patch` | Interactive staging |
| `gau` | `git add --update` | Stage modified files only |
| `gav` | `git add --verbose` | Verbose staging |

### Commits

| Command | Full Command | Description |
|---------|--------------|-------------|
| `gc` | `git commit -v` | Commit with verbose |
| `gc!` | `git commit -v --amend` | Amend last commit |
| `gcn!` | `git commit --no-edit --amend` | Amend without editing |
| `gca` | `git commit -v -a` | Commit all changes |
| `gca!` | `git commit -v -a --amend` | Amend all changes |
| `gcam` | `git commit -a -m` | Commit all with message |
| `gcmsg` | `git commit -m` | Commit with message |
| `gcsm` | `git commit -s -m` | Signed commit |

### Branching

| Command | Full Command | Description |
|---------|--------------|-------------|
| `gb` | `git branch` | List branches |
| `gba` | `git branch -a` | List all branches |
| `gbd` | `git branch -d` | Delete branch |
| `gbD` | `git branch -D` | Force delete branch |
| `gco` | `git checkout` | Checkout branch/file |
| `gcb` | `git checkout -b` | Create and checkout |
| `gcm` | `git checkout main/master` | Checkout main |
| `gcd` | `git checkout develop` | Checkout develop |

### Remote Operations

| Command | Full Command | Description |
|---------|--------------|-------------|
| `gf` | `git fetch` | Fetch from remote |
| `gfa` | `git fetch --all --prune` | Fetch all with cleanup |
| `gfo` | `git fetch origin` | Fetch from origin |
| `gl` | `git pull` | Pull from remote |
| `ggl` | `git pull origin $(branch)` | Pull current branch |
| `gp` | `git push` | Push to remote |
| `ggp` | `git push origin $(branch)` | Push current branch |
| `gpsup` | `git push --set-upstream origin $(branch)` | Push with upstream |
| `gpd` | `git push --dry-run` | Dry run push |
| `gpf!` | `git push --force` | Force push (careful!) |

### Rebasing

| Command | Full Command | Description |
|---------|--------------|-------------|
| `grb` | `git rebase` | Start rebase |
| `grba` | `git rebase --abort` | Abort rebase |
| `grbc` | `git rebase --continue` | Continue rebase |
| `grbi` | `git rebase -i` | Interactive rebase |
| `grbs` | `git rebase --skip` | Skip commit |

### Stashing

| Command | Full Command | Description |
|---------|--------------|-------------|
| `gsta` | `git stash save` | Stash changes |
| `gstaa` | `git stash apply` | Apply stash |
| `gstc` | `git stash clear` | Clear all stashes |
| `gstd` | `git stash drop` | Drop stash |
| `gstl` | `git stash list` | List stashes |
| `gstp` | `git stash pop` | Pop stash |
| `gsts` | `git stash show` | Show stash |

### Resetting

| Command | Full Command | Description |
|---------|--------------|-------------|
| `grh` | `git reset` | Reset HEAD |
| `grhh` | `git reset --hard` | Hard reset |
| `groh` | `git reset origin/$(branch) --hard` | Reset to origin |
| `gru` | `git reset --` | Unstage files |
| `grv` | `git revert` | Revert commit |

### Diff & Logs

| Command | Full Command | Description |
|---------|--------------|-------------|
| `gd` | `git diff` | Show changes |
| `gdca` | `git diff --cached` | Show staged changes |
| `gdcw` | `git diff --cached --word-diff` | Word diff staged |
| `gds` | `git diff --staged` | Show staged changes |
| `gdw` | `git diff --word-diff` | Word-level diff |
| `glog` | `git log --graph --pretty` | Pretty log graph |
| `glol` | `git log --graph --oneline` | Oneline graph |
| `glola` | `git log --graph --oneline --all` | All branches graph |

## Custom Git Commands

### Semantic Commits

| Command | Example | Result |
|---------|---------|--------|
| `git feat` | `git feat "add user auth"` | `feat: add user auth` |
| `git fix` | `git fix "null pointer"` | `fix: null pointer` |
| `git docs` | `git docs "update readme"` | `docs: update readme` |
| `git style` | `git style "format code"` | `style: format code` |
| `git refactor` | `git refactor "extract method"` | `refactor: extract method` |
| `git test` | `git test "add unit tests"` | `test: add unit tests` |
| `git chore` | `git chore "update deps"` | `chore: update deps` |

### Utility Commands

| Command | Description |
|---------|-------------|
| `git undo` | Undo last commit (keep changes) |
| `git uncommit` | Alias for `git undo` |
| `git cleanup` | Delete merged branches |
| `git yolo` | Add all, commit "YOLO", push |
| `git standup` | Show commits since yesterday |
| `git who` | Show author statistics |

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

## GitHub CLI Integration

| Command | Description |
|---------|-------------|
| `gh pr create` | Create pull request |
| `gh pr list` | List PRs |
| `gh pr checkout` | Checkout PR locally |
| `gh pr merge` | Merge PR |
| `gh issue create` | Create issue |
| `gh repo clone` | Clone repository |

---

<p align="center">
  <a href="../README.md">← Back to Usage</a>
</p>