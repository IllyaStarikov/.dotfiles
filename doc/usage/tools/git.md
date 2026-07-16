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

| Command           | Alias | Description           |
| ----------------- | ----- | --------------------- |
| `git init`        |       | Initialize repository |
| `git clone url`   |       | Clone repository      |
| `git status`      | `gs`  | Show status           |
| `git log --graph` | `gl`  | View history (graph)  |
| `git remote -v`   |       | List remotes          |

### Basic Workflow

| Command               | Alias | Description         |
| --------------------- | ----- | ------------------- |
| `git add .`           | `gaa` | Stage all changes   |
| `git add file`        | `ga`  | Stage specific file |
| `git commit -m "msg"` | `gcm` | Commit with message |
| `git push`            | `gp`  | Push to remote      |
| `git pull`            | `gpl` | Pull from remote    |

## Advanced Aliases

### Staging and Committing

| Alias    | Command                                | Description         |
| -------- | -------------------------------------- | ------------------- |
| `ga`     | `git add`                              | Stage files         |
| `gaa`    | `git add --all`                        | Add all files       |
| `gcm`    | `git commit -m`                        | Commit with message |
| `gca`    | `git commit --amend`                   | Amend last commit   |
| `gwip`   | `git add -A && git commit -m 'WIP...'` | Quick WIP commit    |
| `gunwip` | Reset last commit if it is a WIP       | Drop WIP commit     |

For interactive staging use the full command `git add -p` (no alias). The git-native
`git amend` (`commit --amend --no-edit`) amends without opening the editor.

### Branching

| Alias      | Command                                    | Description          |
| ---------- | ------------------------------------------ | -------------------- |
| `gb`       | `git branch`                               | List branches        |
| `gba`      | `git branch -a`                            | List all branches    |
| `gb -d`    | `git branch -d`                            | Delete branch        |
| `gb -D`    | `git branch -D`                            | Force delete branch  |
| `gco`      | `git checkout`                             | Switch branch        |
| `gcb`      | `git checkout -b`                          | Create and switch    |
| `gco -`    | `git checkout -`                           | Previous branch      |
| `gco main` | `git checkout main`                        | Switch to main       |
| `gfresh`   | Checkout main, pull, prune merged branches | Fresh start on main  |

### Semantic Branch Creation

Use `gcb` (`git checkout -b`) with a conventional prefix:

```bash
gcb feature/feature-name   # feature branch
gcb fix/bug-description    # bugfix branch
gcb chore/task-name        # chore branch
gcb docs/update-name       # documentation branch
gcb refactor/scope         # refactor branch
gcb test/test-name         # test branch
gcb style/change-name      # style branch
gcb perf/optimization      # performance branch
```

### Remote Operations

| Alias               | Command                   | Description       |
| ------------------- | ------------------------- | ----------------- |
| `gf`                | `git fetch`               | Fetch from remote |
| `gf origin`         | `git fetch origin`        | Fetch from origin |
| `gp`                | `git push`                | Push to remote    |
| `gp -u origin HEAD` | `git push -u origin HEAD` | Push and track    |

There is no force-push alias; use the full command `git push --force-with-lease`, which
refuses to clobber work someone else pushed.

### Pulling and Rebasing

| Alias          | Command             | Description        |
| -------------- | ------------------- | ------------------ |
| `gpl`          | `git pull`          | Pull from remote   |
| `gpl --rebase` | `git pull --rebase` | Pull with rebase   |
| `gr`           | `git rebase`        | Rebase branch      |
| `gri`          | `git rebase -i`     | Interactive rebase |

`git rebase --continue` and `git rebase --abort` have no aliases; use the full commands.

### Stashing

| Alias  | Command         | Description   |
| ------ | --------------- | ------------- |
| `gst`  | `git stash`     | Stash changes |
| `gstp` | `git stash pop` | Pop stash     |

Other stash operations have no alias; use the full commands: `git stash list`,
`git stash apply`, `git stash show`, `git stash drop`, and `git stash clear`.

### Diff and Status

| Alias   | Command             | Description         |
| ------- | ------------------- | ------------------- |
| `gd`    | `git diff`          | Show changes        |
| `gdc`   | `git diff --cached` | Show staged changes |
| `gs`    | `git status`        | Show status         |
| `git s` | `git status -sb`    | Short status        |

For word-level diffs use the full command `git diff --word-diff` (no alias).

### History and Logs

| Alias   | Command                                      | Description             |
| ------- | -------------------------------------------- | ----------------------- |
| `gl`    | `git log --graph` (pretty format)            | Graph log               |
| `gll`   | `git log --graph --all` (pretty format)      | Graph log, all branches |
| `glo`   | `git log --oneline --graph --decorate --all` | One-line graph          |
| `git l` | `git log --oneline --graph --decorate -20`   | Last 20 commits         |

For stats or patches use the full commands `git log --stat` and `git log --stat -p`.

### Reset and Clean

| Alias      | Command                   | Description            |
| ---------- | ------------------------- | ---------------------- |
| `greset`   | `git reset --hard HEAD`   | Hard reset to HEAD     |
| `gundo`    | `git reset --soft HEAD~1` | Undo last commit       |
| `git undo` | `git reset --soft HEAD~1` | Undo last commit (git) |
| `gclean`   | `git clean -fd`           | Remove untracked files |

A plain `git reset` (unstage) has no alias. To reset to the remote branch, run
`git reset --hard origin/$(git branch --show-current)`. For a fully pristine tree:
`greset && git clean -fdx`.

### Merge and Cherry-pick

| Alias | Command     | Description  |
| ----- | ----------- | ------------ |
| `gm`  | `git merge` | Merge branch |

No aliases exist for `git merge --abort`, `git merge --squash`, `git cherry-pick`, or the
cherry-pick `--abort`/`--continue` forms; use the full commands.

## Git Workflows

### Feature Branch Workflow

```bash
# 1. Start from main
gco main
gpl

# 2. Create feature branch
gcb feature/new-widget

# 3. Work and commit
ga .
gcm "feat: add new widget component"

# 4. Push to remote
gp -u origin HEAD

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
gcm "fix: resolve critical memory leak"

# 3. Push and create PR
gp -u origin HEAD
gh pr create --label hotfix
```

### Rebase Workflow

```bash
# 1. Update feature branch
gco feature/branch
gr main

# 2. Resolve conflicts
git status
# Edit conflicts
ga .
git rebase --continue

# 3. Force push
git push --force-with-lease
```

### Squash Commits

```bash
# Interactive rebase last 3 commits
gri HEAD~3

# In editor, change 'pick' to 'squash'
# for commits to combine

# Force push
git push --force-with-lease
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

| Issue              | Solution                                  |
| ------------------ | ----------------------------------------- |
| Merge conflicts    | Edit files, `ga`, `git rebase --continue` |
| Wrong branch       | `git reflog`, recover                     |
| Need to undo       | `gundo` or `git reset`                    |
| Dirty working tree | `gst` to stash                            |

### Emergency Commands

```bash
# Abort everything
git merge --abort
git rebase --abort
git cherry-pick --abort

# Reset to remote
git reset --hard origin/$(git branch --show-current)

# Complete reset (hard reset + remove all untracked files)
greset && git clean -fdx
```

## Quick Reference Card

```bash
# Daily workflow
gs          # Status
gaa         # Add all
gcm ""      # Commit
gp          # Push
gpl         # Pull

# Branches
gco main      # Switch to main
gcb feature   # New branch
gb -d feature # Delete branch

# History
gl          # Log (graph)
gd          # Diff
gundo       # Undo last

# Stash
gst         # Stash
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
