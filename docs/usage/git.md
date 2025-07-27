# Git Configuration & Usage Guide

## Command/Shortcut Reference Table

### Basic Git Aliases
| Alias | Command | Description |
|-------|---------|-------------|
| `st` | `status` | Show working tree status |
| `ci` | `commit` | Commit staged changes |
| `co` | `checkout` | Switch branches or restore files |
| `br` | `branch` | List, create, or delete branches |
| `cp` | `cherry-pick` | Apply commits from another branch |
| `df` | `diff` | Show changes not staged |
| `dc` | `diff --cached` | Show staged changes |

### Advanced Operations
| Alias | Command | Description |
|-------|---------|-------------|
| `unstage` | `reset HEAD --` | Unstage files |
| `uncommit` | `reset --soft HEAD~1` | Undo last commit, keep changes |
| `recommit` | `commit --amend --no-edit` | Amend last commit |
| `assume` | `update-index --assume-unchanged` | Ignore file changes |
| `unassume` | `update-index --no-assume-unchanged` | Track file again |
| `assumed` | Shows assumed files | List ignored files |

### Branch Management
| Alias | Command | Description |
|-------|---------|-------------|
| `brd` | `branch -D` | Force delete branch |
| `brm` | `branch -m` | Rename branch |
| `brc` | `checkout -b` | Create and switch branch |
| `cleanup` | Custom command | Delete merged branches |
| `activity` | Custom command | Show branch activity |

### Log Viewing
| Alias | Command | Description |
|-------|---------|-------------|
| `l` | Pretty log | Oneline graph with decorations |
| `ll` | Pretty log all | Include all branches |
| `lp` | Pretty format | Colored author and time |
| `lg` | Graph log | Beautiful tree view |
| `standup` | Yesterday's commits | Your commits since yesterday |
| `who` | `shortlog -sne` | Commit count by author |

### Workflow Helpers
| Alias | Command | Description |
|-------|---------|-------------|
| `wip` | Quick WIP commit | Stage all and commit as WIP |
| `unwip` | Undo WIP | Remove last WIP commit |
| `f` | Find files | Case-insensitive file search |
| `grep` | Search content | Case-insensitive grep |
| `prune-all` | Prune remotes | Clean up all remotes |

### Stash Operations
| Alias | Command | Description |
|-------|---------|-------------|
| `stash-unapply` | Reverse stash | Undo stash apply |
| `stash-rename` | Rename stash | Give stash a better name |

### Commit Type Shortcuts
| Alias | Command | Description |
|-------|---------|-------------|
| `feat` | Feature commit | `feat: <message>` |
| `fix` | Bug fix commit | `fix: <message>` |
| `docs` | Documentation | `docs: <message>` |
| `style` | Style changes | `style: <message>` |
| `refactor` | Code refactor | `refactor: <message>` |
| `test` | Test changes | `test: <message>` |
| `chore` | Maintenance | `chore: <message>` |

### Diff Variants
| Alias | Command | Description |
|-------|---------|-------------|
| `word-diff` | Word-level diff | Show word changes |
| `char-diff` | Character diff | Show character changes |

### Interactive Rebase
| Alias | Command | Description |
|-------|---------|-------------|
| `ri` | `rebase -i` | Interactive rebase |
| `rc` | `rebase --continue` | Continue rebase |
| `ra` | `rebase --abort` | Abort rebase |

### Submodule Helpers
| Alias | Command | Description |
|-------|---------|-------------|
| `subi` | Init submodules | Initialize and update |
| `subu` | Update submodules | Update to latest |

## Quick Reference

### Core Settings
- **Editor**: Neovim for commit messages and conflicts
- **Default branch**: `main` (not master)
- **Pull strategy**: Rebase by default
- **Push behavior**: Simple with auto-setup
- **Merge style**: No fast-forward, diff3 conflicts
- **Performance**: Optimized for large repos

### Safety Features
- **safecrlf**: Warns about line ending issues
- **Autocorrect**: Suggests correct commands
- **Rerere**: Remembers resolved conflicts
- **Commit verbose**: Shows diff in commit message
- **Auto stash**: Stashes changes during rebase

### Color Configuration
- Colored output for all commands
- Semantic colors for different elements
- Whitespace errors highlighted
- Moved code detection in diffs

## About

This Git configuration provides:

- **Professional workflow** aliases and shortcuts
- **Safety features** to prevent common mistakes
- **Performance optimizations** for large repositories
- **Modern conventions** like main branch and commit types
- **Enhanced diffs** with better algorithms
- **Tool integrations** with Neovim and GitHub CLI

## Additional Usage Info

### Global Ignore Patterns
The `.gitignore` file includes:
- OS files: `.DS_Store`, `Thumbs.db`
- Editor files: `.swp`, `*~`, `.idea`
- Build artifacts: `*.log`, `node_modules`
- Security: `.env`, `*.pem`

### Merge Conflict Resolution
Using Neovim as mergetool:
1. `git mergetool` opens Neovim with 3-way diff
2. Navigate between conflicts with `]c` and `[c`
3. Choose version with `:diffget LOCAL/REMOTE/BASE`
4. Save and exit to mark as resolved

### URL Shortcuts
- `git@github.com:` preferred over HTTPS
- Automatic URL rewriting for better performance
- GitHub CLI integration for authentication

### Performance Settings
- Parallel pack operations
- Optimized delta compression
- Large pack size limits
- Fast index version
- Untracked cache enabled
- File system monitor active

## Further Command Explanations

### Smart Aliases

**`cleanup` Command**:
```bash
git branch --merged | grep -v '\*\|main\|master\|develop' | xargs -n 1 git branch -d
```
Safely deletes all branches merged into current branch.

**`activity` Command**:
Shows all branches sorted by last commit date with author info.

**`assumed` Command**:
Lists files marked with `--assume-unchanged` flag.

### Conventional Commits
The commit type aliases follow the Conventional Commits specification:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation only
- `style`: Formatting, missing semicolons, etc.
- `refactor`: Code change that neither fixes nor adds
- `test`: Adding missing tests
- `chore`: Maintain tasks, dependencies

### Advanced Diff Options
- **Patience algorithm**: Better for code refactoring
- **Compaction heuristic**: Groups related changes
- **Color moved**: Shows moved code blocks
- **Word diff regex**: Customizable word boundaries

### Rerere (Reuse Recorded Resolution)
Automatically applies previous conflict resolutions:
1. Enabled globally
2. Records how you resolve conflicts
3. Applies same resolution in future
4. Huge time saver for repeated merges

## Theory & Background

### Git Philosophy
This configuration embraces:
- **Atomic commits**: Small, focused changes
- **Clean history**: Rebase for linear history
- **Branch hygiene**: Regular cleanup
- **Semantic messages**: Clear commit intent

### Rebase vs Merge
Default to rebase because:
- Cleaner, linear history
- Easier to bisect
- No merge commits clutter
- Better for code review

### Performance Optimizations
For large repositories:
- FSMonitor tracks file changes
- Untracked cache speeds status
- Pack optimizations reduce size
- Parallel processing where possible

## Good to Know / Lore / History

### Evolution of Defaults
- `master` → `main`: Industry-wide change
- HTTP → SSH: Better security and performance
- Merge → Rebase: Cleaner history preference

### Hidden Features

1. **Auto-correction**: Git suggests correct command after 0.1s
2. **Commit templates**: Set with `commit.template`
3. **Conditional includes**: Different configs per directory
4. **Push options**: `--force-with-lease` for safety
5. **Reflog**: Your safety net for "lost" commits

### Integration Points

**GitHub CLI**:
- Credential helper integration
- Works with git commands
- PR and issue management

**Neovim Integration**:
- Fugitive plugin compatibility
- Syntax highlighting in commits
- Three-way merge interface

**Shell Integration**:
- Aliases stack with shell aliases
- Completion works with all aliases
- Prompt shows git status

### Common Workflows

**Feature Branch**:
```bash
git brc feature/new-thing  # Create branch
# ... make changes ...
git wip                    # Quick save
git unwip                  # Continue work
git feat "Add new thing"   # Semantic commit
git push -u origin HEAD    # Push with tracking
```

**Cleanup Routine**:
```bash
git co main
git pull
git cleanup               # Remove merged branches
git prune-all            # Clean up remotes
```

**Interactive Rebase**:
```bash
git ri HEAD~3            # Rebase last 3 commits
# Mark commits to squash/edit/reorder
git rc                   # Continue after changes
```

### Pro Tips

1. **Use semantic commits** - Makes history searchable
2. **Alias everything** - Save keystrokes
3. **Learn reflog** - It's your safety net
4. **Use rerere** - Conflict resolution memory
5. **Prune regularly** - Keep repo clean
6. **Assume unchanged** - For local config files
7. **Interactive rebase** - Clean up before pushing
8. **Stash creatively** - Name your stashes

### Performance Tips

1. **Clone with depth** - For large repos: `--depth 1`
2. **Sparse checkout** - Work with repo subset
3. **Bundle for offline** - Create bundle files
4. **Use SSH** - Faster than HTTPS
5. **Enable FSMonitor** - Faster status checks
6. **Pack regularly** - `git gc --aggressive`