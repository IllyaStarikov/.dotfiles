# Git Reference

## Daily Commands
```
BASIC                  BRANCH                 REMOTE
gs      Status         gco -b name  New       gp    Push
gaa     Add all        gco main     Switch    gl    Pull
gcmsg   Commit         gb           List      gpsup Set upstream
gd      Diff          gbd name     Delete    gfa   Fetch all
glog    Log           gbr          Remote    grhh  Reset hard

STASH                 HISTORY                FIX
gsta    Stash         glog    Graph log     gc!   Amend
gstp    Pop           gloga   All branches  grbi  Interactive rebase
gstl    List          glol    Oneline       grhh  Reset hard HEAD
gstd    Show          blame   Who changed   gclean Remove untracked
```

## Essential Commands

| Command | Action | Alias | Action |
|---------|--------|-------|--------|
| `git init` | Initialize | `gi` | init |
| `git clone url` | Clone | `gcl` | clone |
| `git add .` | Stage all | `gaa` | add all |
| `git commit -m` | Commit | `gcmsg` | commit message |
| `git push` | Push | `gp` | push |
| `git pull` | Pull | `gl` | pull |
| `git status` | Status | `gs` | status |
| `git log` | History | `glog` | pretty log |

## Staging & Commits

| Command | Action | Alias | Action |
|---------|--------|-------|--------|
| `git add file` | Stage file | `ga` | add |
| `git add -p` | Stage hunks | `gap` | add patch |
| `git reset file` | Unstage | `grh` | reset |
| `git commit` | Commit | `gc` | commit |
| `git commit --amend` | Amend | `gc!` | amend |
| `git commit -a` | Commit all | `gca` | commit all |

## Branches

| Command | Action | Alias | Action |
|---------|--------|-------|--------|
| `git branch` | List | `gb` | branch |
| `git branch -a` | All | `gba` | branch all |
| `git checkout -b` | Create | `gcb` | checkout -b |
| `git checkout` | Switch | `gco` | checkout |
| `git branch -d` | Delete | `gbd` | branch delete |
| `git branch -D` | Force delete | `gbD` | force delete |
| `git merge` | Merge | `gm` | merge |

## Remote Operations

| Command | Action | Alias | Action |
|---------|--------|-------|--------|
| `git remote -v` | List remotes | `grv` | remote -v |
| `git fetch` | Fetch | `gf` | fetch |
| `git fetch --all` | Fetch all | `gfa` | fetch all |
| `git pull --rebase` | Pull rebase | `gup` | pull rebase |
| `git push -u` | Set upstream | `gpsup` | push upstream |
| `git push --force` | Force push | `gpf!` | force push |

## Stashing

| Command | Action | Alias | Action |
|---------|--------|-------|--------|
| `git stash` | Stash | `gsta` | stash |
| `git stash pop` | Pop | `gstp` | stash pop |
| `git stash list` | List | `gstl` | stash list |
| `git stash drop` | Drop | `gstd` | stash drop |
| `git stash apply` | Apply | `gstaa` | stash apply |
| `git stash show` | Show | `gsts` | stash show |

## History & Logs

| Command | Action | Alias | Action |
|---------|--------|-------|--------|
| `git log --graph` | Graph | `glog` | graph log |
| `git log --oneline` | Oneline | `glol` | log oneline |
| `git log --all` | All branches | `gloga` | log all |
| `git log -p` | With patches | `glp` | log patch |
| `git reflog` | Reference log | `grl` | reflog |
| `git blame` | Blame | `gbl` | blame |

## Diffs

| Command | Action | Alias | Action |
|---------|--------|-------|--------|
| `git diff` | Working diff | `gd` | diff |
| `git diff --staged` | Staged diff | `gds` | diff staged |
| `git diff HEAD` | All changes | `gdh` | diff HEAD |
| `git diff branch` | Branch diff | `gdb` | diff branch |

## Reset & Revert

| Command | Action | Alias | Action |
|---------|--------|-------|--------|
| `git reset --soft` | Soft reset | `grh` | reset |
| `git reset --hard` | Hard reset | `grhh` | reset hard |
| `git reset HEAD~1` | Undo commit | `grh~1` | reset 1 |
| `git revert` | Revert | `grev` | revert |
| `git clean -fd` | Clean | `gclean` | clean |

## Rebase

| Command | Action | Alias | Action |
|---------|--------|-------|--------|
| `git rebase` | Rebase | `grb` | rebase |
| `git rebase -i` | Interactive | `grbi` | rebase -i |
| `git rebase --abort` | Abort | `grba` | abort |
| `git rebase --continue` | Continue | `grbc` | continue |
| `git rebase main` | On main | `grbm` | rebase main |

## Config

| Command | Purpose |
|---------|---------|
| `git config --global user.name "Name"` | Set name |
| `git config --global user.email "email"` | Set email |
| `git config --global core.editor nvim` | Set editor |
| `git config --list` | List config |
| `git config --global alias.st status` | Create alias |

## Advanced Aliases

| Alias | Command | Purpose |
|-------|---------|---------|
| `grhh` | `reset --hard HEAD` | Reset everything |
| `grhh~1` | `reset --hard HEAD~1` | Undo last commit |
| `grbi` | `rebase -i` | Interactive rebase |
| `grbc` | `rebase --continue` | Continue rebase |
| `grba` | `rebase --abort` | Abort rebase |
| `gpsup` | `push --set-upstream origin HEAD` | Push new branch |
| `gfa` | `fetch --all --prune` | Fetch everything |
| `gclean` | `clean -fd` | Remove untracked |
| `gwip` | Add all & commit WIP | Work in progress |
| `gunwip` | Undo WIP commit | Remove WIP |
| `gcp` | Cherry-pick | Cherry-pick commit |

## Custom Git Aliases

| Alias | Purpose | Example |
|-------|---------|---------|
| `git st` | Status shortcut | `git st` |
| `git ci` | Commit shortcut | `git ci -m "msg"` |
| `git co` | Checkout shortcut | `git co branch` |
| `git br` | Branch shortcut | `git br -a` |
| `git cp` | Cherry-pick | `git cp hash` |
| `git unstage` | Unstage files | `git unstage file` |
| `git uncommit` | Undo commit soft | `git uncommit` |
| `git recommit` | Amend no edit | `git recommit` |
| `git word-diff` | Word-level diff | `git word-diff` |
| `git who` | Contributor stats | `git who` |
| `git standup` | Yesterday's work | `git standup` |
| `git cleanup` | Delete merged branches | `git cleanup` |
| `git aliases` | List all aliases | `git aliases` |

## Commit Type Shortcuts

| Command | Creates | Example |
|---------|---------|---------|  
| `git feat "msg"` | feat: msg | `git feat "add login"` |
| `git fix "msg"` | fix: msg | `git fix "null pointer"` |
| `git docs "msg"` | docs: msg | `git docs "update readme"` |
| `git style "msg"` | style: msg | `git style "format code"` |
| `git refactor "msg"` | refactor: msg | `git refactor "extract method"` |
| `git test "msg"` | test: msg | `git test "add unit tests"` |
| `git chore "msg"` | chore: msg | `git chore "update deps"` |

## Workflows

### Feature Branch
```bash
gco -b feature/new    # Create branch
# work...
gaa                   # Add all
gcmsg "feat: add X"   # Commit
gpsup                 # Push & set upstream
```

### Update Branch
```bash
gfa                   # Fetch all
grb origin/main       # Rebase on main
# or
gl --rebase           # Pull with rebase
```

### Quick Fix
```bash
# Forgot file in commit
ga forgotten.txt
gc! -n               # Amend, no edit

# Wrong branch
gco correct-branch
gcp wrong-branch~0  # Cherry-pick
```

### Undo Operations
```bash
grh HEAD~1          # Undo commit, keep changes
grhh HEAD~1         # Undo commit, discard changes
grev HEAD           # Revert (new commit)
grh file.txt        # Unstage file
gco -- file.txt     # Discard changes
```

## Merge Conflicts

| Step | Command | Purpose |
|------|---------|---------|
| 1 | `gs` | See conflicts |
| 2 | Edit files | Resolve conflicts |
| 3 | `ga file` | Mark resolved |
| 4 | `gc` | Complete merge |
| Abort | `gm --abort` | Cancel merge |

## GitHub CLI

| Command | Action | Command | Action |
|---------|--------|---------|--------|
| `gh pr create` | Create PR | `gh pr list` | List PRs |
| `gh pr view` | View PR | `gh pr merge` | Merge PR |
| `gh issue create` | New issue | `gh issue list` | List issues |
| `gh repo clone` | Clone repo | `gh repo fork` | Fork repo |

## Tips

- Use `gaa && gcmsg "message" && gp` for quick commits
- `grhh` to abandon all changes
- `grbi HEAD~3` to clean up last 3 commits
- `gsta` before switching branches
- `gfa && grb origin/main` to update feature branch
- `gl --rebase` instead of `gl` to avoid merge commits
- Use `gc!` to amend last commit
- `glog` for visual branch history