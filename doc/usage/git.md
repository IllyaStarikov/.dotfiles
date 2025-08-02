# Git Commands

## Daily Commands

```bash
BASIC                  BRANCH                 REMOTE
gs      Status         gco -b name  New       gp    Push
gaa     Add all        gco main     Switch    gl    Pull
gcmsg   Commit         gb           List      gpsup Set upstream
gd      Diff          gbd name     Delete    gfa   Fetch all
glog    Log           gbr          Remote    grhh  Reset hard

STASH                 HISTORY                FIX MISTAKES
gsta    Stash         glog    Graph log     gc!   Amend
gstp    Pop           gloga   All branches  grbi  Interactive rebase
gstl    List          glol    Oneline       grhh  Reset hard HEAD
gstd    Drop          gbl     Blame         gclean Remove untracked

SEMANTIC              GITHUB                 ADVANCED
feat    Feature       gh pr create  New PR   gcp   Cherry-pick
fix     Bug fix       gh pr list    List     gwip  Work in progress  
docs    Documentation gh pr merge   Merge    gunwip Undo WIP
style   Formatting    gh issue new  Create   grev  Revert commit
```

## Git Workflows

### Feature Branch Workflow
```bash
# 1. Start from updated main
gco main              # Switch to main
gl                    # Pull latest changes

# 2. Create feature branch
gco -b feature/awesome-feature

# 3. Work and commit
# ... make changes ...
gaa                   # Add all changes
gcmsg "feat: add awesome feature"

# 4. Push and create PR
gpsup                 # Push with upstream
gh pr create          # Create pull request
```

### Quick Fixes
```bash
# Forgot to add file to last commit
ga forgotten-file.txt
gc! -n                # Amend without editing message

# Wrong branch? Move commit
gco correct-branch    
gcp wrong-branch      # Cherry-pick from wrong branch
gco wrong-branch
grhh HEAD~1          # Remove from wrong branch

# Typo in commit message
gc! -m "feat: corrected message"
```

### Stash Workflow
```bash
# Save work temporarily
gsta -m "work on feature X"    # Named stash
gco main                        # Switch branches
# ... do other work ...
gco feature-branch
gstp                           # Pop stash back

# Advanced stash
gstl                           # List all stashes
gsts                           # Show stash contents
gsta -p                        # Interactive stash
gstaa stash@{1}               # Apply specific stash
```

## Semantic Commits

### Built-in Shortcuts
```bash
git feat "add user authentication"      # feat: add user authentication
git fix "resolve null pointer"          # fix: resolve null pointer
git docs "update API documentation"     # docs: update API documentation
git style "format with prettier"        # style: format with prettier
git refactor "extract helper method"    # refactor: extract helper method
git test "add unit tests for auth"      # test: add unit tests for auth
git chore "update dependencies"         # chore: update dependencies
git perf "optimize database queries"    # perf: optimize database queries
```

### Conventional Commit Format
```
<type>(<scope>): <subject>

<body>

<footer>
```

Examples:
```bash
feat(auth): add OAuth2 integration

Implement Google and GitHub OAuth providers
with proper token refresh handling

Closes #123
```

## Configuration

### Essential Git Config

```bash
# User setup
git config --global user.name "Your Name"
git config --global user.email "you@email.com"

# Performance optimizations
git config --global core.fsmonitor true
git config --global core.untrackedCache true
git config --global fetch.prune true
git config --global rebase.autoStash true
```

### Aliases Power Pack

| Alias | Git Command | Purpose |
|-------|-------------|---------|
| `gaa` | `add --all` | Stage everything |
| `gcm` | `commit -m` | Quick commit with message |
| `gca` | `commit --amend` | Amend last commit |
| `grhh` | `reset --hard HEAD` | Nuclear reset |
| `gri` | `rebase -i` | Interactive rebase |
| `grc` | `rebase --continue` | Continue after conflict |
| `gpsup` | `push -u origin HEAD` | Push with tracking |
| `gclean` | `clean -fd` | Remove untracked files |
| `gwip` | Custom function | Quick WIP commit |
| `gunwip` | Custom function | Undo WIP commit |
| `gcp` | `cherry-pick` | Copy commit |
| `gfa` | `fetch --all --prune` | Fetch & prune all |
| `gl` | Custom log format | Beautiful commit graph |
| `gst` | `stash` | Quick stash |

## Branch Management

### Branch Operations
```bash
# List branches
gb                    # Local branches
gba                   # All branches (local + remote)
gbr                   # Remote branches

# Create and switch
gco -b feature/new    # Create and checkout
gcb feature/new       # Same thing

# Delete branches
gbd feature/done      # Delete merged branch
gbD feature/abandon   # Force delete

# Remote operations
gpsup                 # Push new branch with tracking
gfa                   # Fetch all remotes
git push origin --delete old-branch  # Delete remote
```

### Branch Cleanup
```bash
# Delete merged branches (except main/master/develop)
git cleanup           # Custom alias

# Prune remote tracking branches
git remote prune origin

# See merged/unmerged branches
git branch --merged
git branch --no-merged
```

## Rebase & History

### Interactive Rebase
```bash
# Rebase last 3 commits
grbi HEAD~3

# Rebase onto main
grbm                  # git rebase main

# During rebase
grbc                  # Continue after fixing conflicts
grba                  # Abort rebase
grbs                  # Skip current commit
```

### Rebase Commands
In interactive rebase (`grbi`):
- `pick` - Use commit
- `reword` - Change message
- `edit` - Stop to amend
- `squash` - Meld into previous
- `fixup` - Like squash, discard message
- `drop` - Remove commit

## History & Investigation

### Log Viewing
```bash
glog                  # Graph log with decorations
glol                  # One line per commit
glola                 # All branches, one line
glp                   # Show patches
glo                   # Pretty format log

# Custom searches
git log --grep="fix"  # Search commit messages
git log -S"function"  # Search code changes
git log --author="Name"  # By author
git log --since="2 weeks ago"  # Time range
```

### Blame & Investigation
```bash
gbl file.txt          # Git blame
git blame -L 10,20 file.txt  # Specific lines
git log -p file.txt   # History of file
git log --follow file.txt  # Follow renames
```

## Recovery & Fixes

### Undo Operations
```bash
# Undo last commit (keep changes)
grh HEAD~1

# Undo last commit (discard changes)
grhh HEAD~1

# Undo specific file
gco -- file.txt

# Recover deleted branch
git reflog            # Find the commit
gco -b recovered <sha>

# Undo pushed commit
grev HEAD             # Create revert commit
```

### Conflict Resolution
```bash
# During merge/rebase conflict
gs                    # See conflicted files
# Edit files to resolve
gaa                   # Add resolved files
grbc                  # Continue rebase
# or
gm --continue         # Continue merge
```

### Emergency Commands
```bash
# Lost commits?
git reflog            # See all HEAD movements

# Messed up working directory?
grhh                  # Reset to HEAD

# Wrong merge?
gm --abort            # Abort merge

# Accidentally deleted file?
git checkout HEAD -- deleted-file.txt
```

## GitHub CLI Integration

### Pull Requests
```bash
# Create PR
gh pr create          # Interactive
gh pr create -t "Title" -b "Description"

# Review PRs
gh pr list            # List PRs
gh pr view 123        # View PR #123
gh pr checkout 123    # Checkout PR
gh pr merge 123       # Merge PR

# PR operations
gh pr review --approve
gh pr review --comment -b "LGTM!"
gh pr close
gh pr reopen
```

### Issues
```bash
# Create issue
gh issue create       # Interactive
gh issue create -t "Bug" -b "Description"

# Manage issues
gh issue list         # List issues
gh issue view 45      # View issue
gh issue close 45     # Close issue
gh issue reopen 45    # Reopen
gh issue comment 45 -b "Fixed!"
```

### Repository
```bash
# Clone
gh repo clone owner/repo

# Create
gh repo create my-project --public

# Fork
gh repo fork owner/repo --clone

# View
gh repo view          # Current repo
gh repo view owner/repo  # Specific repo
```

## Advanced Techniques

### Worktrees (Multiple Working Directories)
```bash
# Add worktree for hotfix
git worktree add ../hotfix main
cd ../hotfix
# Work on hotfix while keeping feature branch intact

# List worktrees
git worktree list

# Remove worktree
git worktree remove ../hotfix
```

### Bisect (Find Bad Commits)
```bash
git bisect start
git bisect bad        # Current commit is bad
git bisect good v1.0  # v1.0 was good

# Git will checkout commits to test
# After testing each:
git bisect good       # or
git bisect bad

# When done:
git bisect reset
```

### Submodules
```bash
# Add submodule
git submodule add https://github.com/user/repo path/to/submodule

# Clone with submodules
git clone --recursive <url>

# Update submodules
git submodule update --init --recursive
git submodule update --remote
```

## Git Statistics

### Repository Stats
```bash
# Contributors (gitconfig alias)
git who               # shortlog -sne

# Activity tracking (gitconfig alias)
git activity          # Branch activity with dates

# Your daily standup (gitconfig alias)
git standup           # Your commits since yesterday

# Line count by author
git ls-files | xargs -n1 git blame --line-porcelain | grep "^author " | sort | uniq -c | sort -nr

# Commits per day
git log --format="%ad" --date=short | sort | uniq -c

# File change frequency
git log --format=format: --name-only | grep -v '^$' | sort | uniq -c | sort -rg | head -20
```

## Best Practices

### Commit Guidelines
1. **Atomic commits** - One logical change per commit
2. **Present tense** - "Add feature" not "Added feature"
3. **50 char subject** - Be concise in first line
4. **Blank line** - Between subject and body
5. **72 char wrap** - In body text
6. **Why, not what** - Code shows what, commit shows why

### Branch Naming
```bash
feature/add-user-auth
bugfix/fix-login-error
hotfix/security-patch
chore/update-dependencies
docs/api-documentation
```

### Safety Rules
1. **Never force push to main/master**
2. **Always pull before push**
3. **Review before committing** (`gd`, `gds`)
4. **Use branches** for any significant change
5. **Tag releases** for version tracking

## Pro Tips

### Speed Tricks
```bash
# Quick save everything
gaa && gcmsg "WIP" && gp

# Squash last N commits
grbi HEAD~N  # then fixup/squash

# Find deleted file
git log --all --full-history -- "**/filename.*"

# Cleanup local branches
gb | grep -v "main\|master" | xargs -n 1 git branch -d
```

### Git Configuration Features
```bash
# Commit template (set in gitconfig)
commit.template = ~/.gitmessage
commit.verbose = true    # Show diff in commit editor

# Merge strategy
merge.ff = false         # No fast-forward merges
merge.conflictstyle = diff3  # Show common ancestor

# Better diffs
diff.algorithm = patience
diff.colorMoved = default  # Highlight moved lines

# Auto-correction
help.autocorrect = 1     # Fix typos after 0.1s

# URL rewriting (in gitconfig)
# Automatically use SSH instead of HTTPS for GitHub
url."git@github.com:".insteadOf = "https://github.com/"
```

### Performance Optimizations

```bash
# Configured in gitconfig:
core.untrackedCache = true
core.fsmonitor = true
index.version = 4
pack.threads = 0

# Manual optimization
git gc --aggressive

# Large repo settings
pack.deltaCacheSize = 2g
pack.packSizeLimit = 2g  
pack.windowMemory = 2g
gc.auto = 1000
```

## Troubleshooting

### Common Issues & Solutions

| Problem | Solution |
|---------|----------|
| Detached HEAD | `gco main` or `gco -b new-branch` |
| Permission denied | Check SSH keys: `ssh -T git@github.com` |
| Large files | Use Git LFS: `git lfs track "*.psd"` |
| Merge conflicts | Edit files, then `gaa` and continue |
| Wrong email | `git config user.email "correct@email.com"` |
| Typo in command | Wait 0.1s - autocorrect enabled! |
| Lost work | Check `git reflog` for recovery |
| Need GUI diff | `git difftool` opens nvim diff |

### Reset Scenarios
```bash
# Soft: Keep changes staged
git reset --soft HEAD~1

# Mixed: Keep changes unstaged (default)
git reset HEAD~1

# Hard: Discard all changes
git reset --hard HEAD~1
```

## Advanced Git Features

### Delta Diff Viewer

```bash
# Install delta for better diffs
brew install git-delta
```


### Credential Management

```bash
# GitHub CLI integration
credential.helper = gh auth git-credential
# Handles github.com and gist.github.com
```

### Archive Management
```bash
# Archive old branches (gitconfig alias)
git archive-branch old-feature
# Creates tag 'archive/old-feature' and deletes branch

# List archived branches
git tag -l "archive/*"

# Restore archived branch
git checkout -b old-feature archive/old-feature
```

