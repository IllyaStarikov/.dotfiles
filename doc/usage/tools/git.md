# Git Reference

> **Version control system with powerful aliases**

## Core Configuration

### User Setup

```bash
git config --global user.name "Your Name"
git config --global user.email "email@example.com"
git config --global init.defaultBranch main
```

### Editor and Tools

```bash
git config --global core.editor nvim
git config --global diff.tool vimdiff
git config --global merge.tool vimdiff
git config --global core.pager delta
```

## Essential Commands

### Repository Management

| Command | Alias | Description |
|---------|-------|-------------|
| `git init` | | Initialize repository |
| `git clone url` | `gcl` | Clone repository |
| `git status` | `gs` | Show status |
| `git log` | `gl` | View history |
| `git remote -v` | | List remotes |

### Basic Workflow

| Command | Alias | Description |
|---------|-------|-------------|
| `git add .` | `gaa` | Stage all changes |
| `git add file` | `ga` | Stage specific file |
| `git commit -m "msg"` | `gcmsg` | Commit with message |
| `git push` | `gp` | Push to remote |
| `git pull` | `gl` | Pull from remote |

## Advanced Aliases

### Staging and Committing

| Alias | Command | Description |
|-------|---------|-------------|
| `gaa` | `git add --all` | Add all files |
| `gap` | `git add -p` | Add interactively |
| `gapa` | `git add --patch` | Add by hunks |
| `gau` | `git add --update` | Add modified files |
| `gav` | `git add --verbose` | Verbose add |
| `gcmsg` | `git commit -m` | Commit with message |
| `gc!` | `git commit --amend` | Amend last commit |
| `gca!` | `git commit -a --amend` | Amend with all changes |

### Branching

| Alias | Command | Description |
|-------|---------|-------------|
| `gb` | `git branch` | List branches |
| `gba` | `git branch -a` | List all branches |
| `gbd` | `git branch -d` | Delete branch |
| `gbD` | `git branch -D` | Force delete branch |
| `gco` | `git checkout` | Switch branch |
| `gcb` | `git checkout -b` | Create and switch |
| `gco -` | `git checkout -` | Previous branch |
| `gcm` | `git checkout main` | Switch to main |

### Semantic Branch Creation

```bash
git feat feature-name     # feature/feature-name
git fix bug-description   # fix/bug-description
git chore task-name      # chore/task-name
git docs update-name     # docs/update-name
git refactor scope       # refactor/scope
git test test-name       # test/test-name
git style change-name    # style/change-name
git perf optimization    # perf/optimization
```

### Remote Operations

| Alias | Command | Description |
|-------|---------|-------------|
| `gf` | `git fetch` | Fetch from remote |
| `gfo` | `git fetch origin` | Fetch from origin |
| `gp` | `git push` | Push to remote |
| `gpf` | `git push --force` | Force push |
| `gpf!` | `git push --force` | Force push (alt) |
| `gpsup` | `git push --set-upstream origin $(current_branch)` | Push and track |
| `gpu` | `git push upstream` | Push to upstream |

### Pulling and Rebasing

| Alias | Command | Description |
|-------|---------|-------------|
| `gl` | `git pull` | Pull from remote |
| `glr` | `git pull --rebase` | Pull with rebase |
| `glra` | `git pull --rebase --autostash` | Pull, rebase, autostash |
| `grb` | `git rebase` | Rebase branch |
| `grbi` | `git rebase -i` | Interactive rebase |
| `grbc` | `git rebase --continue` | Continue rebase |
| `grba` | `git rebase --abort` | Abort rebase |

### Stashing

| Alias | Command | Description |
|-------|---------|-------------|
| `gsta` | `git stash push` | Stash changes |
| `gstaa` | `git stash apply` | Apply stash |
| `gstc` | `git stash clear` | Clear all stashes |
| `gstd` | `git stash drop` | Drop stash |
| `gstl` | `git stash list` | List stashes |
| `gstp` | `git stash pop` | Pop stash |
| `gsts` | `git stash show` | Show stash diff |

### Diff and Status

| Alias | Command | Description |
|-------|---------|-------------|
| `gd` | `git diff` | Show changes |
| `gdca` | `git diff --cached` | Show staged changes |
| `gdcw` | `git diff --cached --word-diff` | Staged word diff |
| `gds` | `git diff --staged` | Staged changes |
| `gdw` | `git diff --word-diff` | Word diff |
| `gdt` | `git diff-tree --no-commit-id --name-only -r` | List changed files |

### History and Logs

| Alias | Command | Description |
|-------|---------|-------------|
| `glg` | `git log --stat` | Log with stats |
| `glgp` | `git log --stat -p` | Log with patches |
| `glgg` | `git log --graph` | Log with graph |
| `glgga` | `git log --graph --all` | Full graph |
| `glo` | `git log --oneline` | One line logs |
| `glol` | Pretty one-line log | Decorated log |
| `glola` | Pretty log all branches | Full decorated |

### Reset and Clean

| Alias | Command | Description |
|-------|---------|-------------|
| `grh` | `git reset` | Reset HEAD |
| `grhh` | `git reset --hard` | Hard reset |
| `groh` | `git reset origin/$(current_branch) --hard` | Reset to origin |
| `gclean` | `git clean -id` | Interactive clean |
| `gpristine` | Reset and clean | Full clean |
| `git undo` | `git reset HEAD~` | Undo last commit |

### Merge and Cherry-pick

| Alias | Command | Description |
|-------|---------|-------------|
| `gm` | `git merge` | Merge branch |
| `gma` | `git merge --abort` | Abort merge |
| `gms` | `git merge --squash` | Squash merge |
| `gcp` | `git cherry-pick` | Cherry pick |
| `gcpa` | `git cherry-pick --abort` | Abort cherry pick |
| `gcpc` | `git cherry-pick --continue` | Continue cherry pick |

## Git Workflows

### Feature Branch Workflow

```bash
# 1. Start from main
gco main
gl

# 2. Create feature branch
gcb feature/new-widget

# 3. Work and commit
ga .
gcmsg "feat: add new widget component"

# 4. Push to remote
gpsup

# 5. Create pull request
gh pr create
```

### Hotfix Workflow

```bash
# 1. Create hotfix from main
gco main
gcb hotfix/critical-bug

# 2. Fix and commit
ga patches/fix.patch
gcmsg "fix: resolve critical memory leak"

# 3. Push and create PR
gpsup
gh pr create --label hotfix
```

### Rebase Workflow

```bash
# 1. Update feature branch
gco feature/branch
grb main

# 2. Resolve conflicts
git status
# Edit conflicts
ga .
grbc

# 3. Force push
gpf
```

### Squash Commits

```bash
# Interactive rebase last 3 commits
grbi HEAD~3

# In editor, change 'pick' to 'squash'
# for commits to combine

# Force push
gpf
```

## Advanced Features

### Bisect (Find Breaking Commit)

```bash
git bisect start
git bisect bad                 # Current is bad
git bisect good v1.0          # v1.0 was good

# Test each commit
npm test
git bisect good  # or bad

# When found
git bisect reset
```

### Worktrees

```bash
# Add worktree for feature
git worktree add ../project-feature feature/branch

# List worktrees
git worktree list

# Remove worktree
git worktree remove ../project-feature
```

### Submodules

```bash
# Add submodule
git submodule add https://github.com/user/repo libs/repo

# Update submodules
git submodule update --init --recursive

# Pull with submodules
git pull --recurse-submodules
```

### Reflog (Recovery)

```bash
# View all actions
git reflog

# Recover lost commit
git checkout HEAD@{2}

# Restore branch
git branch recovered-branch HEAD@{1}
```

## GitHub CLI Integration

### Pull Requests

```bash
# Create PR
gh pr create
gh pr create --web

# List PRs
gh pr list
gh pr list --author @me

# Checkout PR
gh pr checkout 123

# Review PR
gh pr review 123 --approve
gh pr review 123 --request-changes
```

### Issues

```bash
# Create issue
gh issue create
gh issue create --title "Bug" --body "Description"

# List issues
gh issue list
gh issue list --assignee @me

# View issue
gh issue view 123
```

## Configuration Tips

### Global Gitignore

```bash
# Create global gitignore
touch ~/.gitignore_global
git config --global core.excludesfile ~/.gitignore_global

# Common ignores
echo ".DS_Store" >> ~/.gitignore_global
echo "*.swp" >> ~/.gitignore_global
echo ".env" >> ~/.gitignore_global
```

### Aliases

```bash
# Add custom aliases
git config --global alias.unstage 'reset HEAD --'
git config --global alias.last 'log -1 HEAD'
git config --global alias.visual '!gitk'
```

### Hooks

```bash
# Pre-commit hook
cat > .git/hooks/pre-commit << 'EOF'
#!/bin/sh
npm test
EOF
chmod +x .git/hooks/pre-commit
```

## Troubleshooting

### Common Issues

| Issue | Solution |
|-------|----------|
| Merge conflicts | Edit files, `ga`, `grbc` |
| Wrong branch | `git reflog`, recover |
| Need to undo | `git undo` or `grh` |
| Dirty working tree | `gsta` to stash |

### Emergency Commands

```bash
# Abort everything
git merge --abort
git rebase --abort
git cherry-pick --abort

# Reset to remote
groh

# Complete reset
gpristine
```

## Quick Reference Card

```bash
# Daily workflow
gs          # Status
gaa         # Add all
gcmsg ""    # Commit
gp          # Push
gl          # Pull

# Branches
gco main    # Switch to main
gcb feature # New branch
gbd feature # Delete branch

# History
gl          # Log
gd          # Diff
git undo    # Undo last

# Stash
gsta        # Stash
gstp        # Pop stash

# GitHub
gh pr create
gh pr list
gh issue create
```

---

<p align="center">
  <a href="../README.md">← Back to Tools</a>
</p>