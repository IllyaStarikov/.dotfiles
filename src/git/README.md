# 🔧 Git Configuration

Modern, secure, and efficient Git configuration optimized for development workflows. Features minimal aliases, enhanced diff viewing, and comprehensive security settings.

## ✨ Features

### 🎯 Modern Workflow
- **Smart defaults**: Sensible configuration for modern Git workflows
- **Security first**: GPG/SSH signing, fsck validation, credential management
- **Enhanced diffs**: Delta integration for beautiful, readable diffs
- **Minimal aliases**: Carefully curated shortcuts for common operations

### 🛡️ Security & Safety
- **Commit signing**: SSH-based commit signing (easier than GPG)
- **Object validation**: fsck checks on all transfers
- **Credential helpers**: Secure GitHub integration via gh CLI
- **Pre-commit hooks**: Gitleaks integration for secret detection

### 🎨 Visual Enhancement
- **Delta pager**: Side-by-side diffs with syntax highlighting
- **Color scheme**: Consistent with terminal theme system
- **Line numbers**: Clear diff navigation
- **Graph visualization**: Beautiful commit history display

## 📁 File Structure

```
src/git/
├── gitconfig              # Main Git configuration
├── gitignore             # Global ignore patterns
├── gitmessage            # Commit message template
├── gitleaks.toml         # Secret detection configuration
├── install-git-hooks     # Git hooks installer script
├── pre-commit-hook       # Pre-commit validation
├── setup-git-signing     # GPG/SSH signing setup
└── README.md             # This documentation
```

## 🔧 Core Configuration Files

### gitconfig - Main Configuration

Modern Git settings optimized for developer productivity.

**User Configuration:**
```ini
[user]
    name = Your Name
    email = your.email@domain.com
    signingkey = ~/.ssh/id_rsa.pub  # SSH signing key
```

**Core Settings:**
```ini
[core]
    editor = nvim                   # Modern editor
    pager = delta                   # Enhanced diff viewer
    excludesfile = ~/.gitignore     # Global ignores

[init]
    defaultBranch = main            # Modern default branch

[pull]
    rebase = true                   # Clean history

[push]
    autoSetupRemote = true          # Auto-setup tracking
```

**Security & Performance:**
```ini
[commit]
    gpgsign = true                  # Sign all commits
    template = ~/.gitmessage        # Commit message template

[gpg]
    format = ssh                    # SSH signing (easier than GPG)

[transfer]
    fsckobjects = true              # Validate objects
```

### Essential Aliases

Minimal but powerful Git shortcuts:

```ini
[alias]
    # Status and information
    s = status -sb                  # Short status with branch
    l = log --oneline --graph --decorate -20  # Pretty log

    # Basic operations
    a = add                         # Stage files
    c = commit                      # Commit changes
    p = push                        # Push to remote
    pl = pull                       # Pull from remote
    co = checkout                   # Switch branches
    b = branch                      # List/create branches

    # Workflow shortcuts
    aa = add --all                  # Stage all changes
    cm = commit -m                  # Commit with message
    undo = reset --soft HEAD~1      # Undo last commit
    amend = commit --amend --no-edit  # Amend without editing
    main = checkout main            # Quick main branch switch
    wip = !git add -A && git commit -m 'WIP'  # Work in progress
```

### gitignore - Global Patterns

Comprehensive ignore patterns for development:

**System Files:**
```gitignore
# macOS
.DS_Store
.AppleDouble
.LSOverride

# Windows
Thumbs.db
ehthumbs.db
Desktop.ini

# Linux
*~
.nfs*
```

**Development Tools:**
```gitignore
# IDEs
.vscode/
.idea/
*.swp
*.swo

# Build artifacts
node_modules/
target/
build/
dist/

# Environment files
.env
.env.local
*.log
```

### gitmessage - Commit Template

Structured commit message template for consistency:

```
# <type>(<scope>): <subject>
#
# <body>
#
# <footer>

# Type: feat, fix, docs, style, refactor, test, chore
# Scope: component, file, or area affected
# Subject: imperative, present tense, lowercase, no period
# Body: motivation for change and contrast with previous behavior
# Footer: reference issues, breaking changes

# Examples:
# feat(auth): add OAuth2 integration
# fix(api): handle null response from external service
# docs(readme): update installation instructions
```

### gitleaks.toml - Secret Detection

Configuration for detecting secrets in commits:

```toml
[extend]
useDefault = true

[[rules]]
description = "AWS Access Key"
regex = '''AKIA[0-9A-Z]{16}'''
tags = ["key", "AWS"]

[[rules]]
description = "GitHub Token"
regex = '''ghp_[0-9a-zA-Z]{36}'''
tags = ["key", "GitHub"]

# Custom patterns for your organization
[[rules]]
description = "Custom API Key"
regex = '''api[_-]?key[_-]?[0-9a-f]{32}'''
tags = ["key", "custom"]
```

## 🔧 Scripts & Utilities

### install-git-hooks - Hook Installer

Installs and configures Git hooks for the repository:

**Features:**
- **Pre-commit validation**: Runs linting, tests, secret detection
- **Commit message validation**: Enforces conventional commit format
- **Backup existing hooks**: Safe installation process
- **Cross-platform**: Works on macOS and Linux

**Usage:**
```bash
./install-git-hooks              # Install all hooks
./install-git-hooks --pre-commit # Install pre-commit only
./install-git-hooks --remove     # Remove installed hooks
```

### pre-commit-hook - Validation Script

Comprehensive pre-commit validation:

**Checks Performed:**
- **Secret detection**: Gitleaks scan for sensitive data
- **Code formatting**: Language-specific formatters
- **Linting**: Style and error checking
- **Test execution**: Run relevant test suites
- **File validation**: Check for merge conflicts, whitespace

**Configuration:**
```bash
# Enable/disable checks
export SKIP_GITLEAKS=false
export SKIP_FORMATTING=false
export SKIP_TESTS=false
```

### setup-git-signing - Signing Configuration

Automated setup for commit signing:

**SSH Signing (Recommended):**
```bash
./setup-git-signing --ssh        # Setup SSH signing
./setup-git-signing --ssh-key ~/.ssh/id_ed25519.pub
```

**GPG Signing:**
```bash
./setup-git-signing --gpg        # Setup GPG signing
./setup-git-signing --gpg-key YOUR_GPG_KEY_ID
```

**Features:**
- **Automatic key detection**: Finds existing SSH/GPG keys
- **GitHub integration**: Uploads public keys to GitHub
- **Validation**: Tests signing configuration
- **Backup**: Saves previous configuration

## 🎨 Delta Integration

### Enhanced Diff Viewing

Delta provides beautiful, readable diffs with syntax highlighting:

**Configuration:**
```ini
[delta]
    navigate = true                 # n/N navigation
    light = false                   # Dark theme
    side-by-side = true            # Split view
    line-numbers = true            # Show line numbers
    colorMoved = default           # Highlight moved code
```

**Features:**
- **Syntax highlighting**: Language-aware coloring
- **Side-by-side view**: Easy comparison
- **Navigation**: Jump between changes
- **Theme integration**: Matches terminal colors

**Usage:**
```bash
git diff                          # Automatic delta paging
git log -p                        # Delta in log view
git show HEAD                     # Delta for commit view
```

## 🛡️ Security Features

### Commit Signing

**SSH Signing (Recommended):**
- **Easier setup**: No GPG key management
- **GitHub integration**: Built-in verification
- **Performance**: Faster than GPG
- **Portability**: Works across platforms

**Configuration:**
```ini
[gpg]
    format = ssh

[user]
    signingkey = ~/.ssh/id_rsa.pub

[commit]
    gpgsign = true
```

### Secret Detection

**Gitleaks Integration:**
- **Pre-commit scanning**: Prevent secret commits
- **Custom patterns**: Organization-specific rules
- **CI/CD integration**: Automated scanning
- **Baseline support**: Ignore existing secrets

**Usage:**
```bash
# Manual scan
gitleaks detect --source . --verbose

# Pre-commit hook automatically runs gitleaks
git commit -m "fix: update API endpoint"
```

### Object Validation

**fsck Configuration:**
```ini
[transfer]
    fsckobjects = true

[receive]
    fsckobjects = true

[fetch]
    fsckobjects = true
```

**Benefits:**
- **Corruption detection**: Validate object integrity
- **Security**: Prevent malicious objects
- **Repository health**: Early problem detection

## 🚀 Workflow Integration

### GitHub CLI Integration

**Credential Helper:**
```ini
[credential "https://github.com"]
    helper = !/opt/homebrew/bin/gh auth git-credential
```

**Benefits:**
- **Seamless authentication**: No manual token management
- **Multi-factor support**: Handles 2FA automatically
- **Token refresh**: Automatic credential renewal

### Branch Management

**Modern Defaults:**
```ini
[init]
    defaultBranch = main

[push]
    default = simple
    autoSetupRemote = true

[pull]
    rebase = true
```

**Workflow Benefits:**
- **Clean history**: Rebase instead of merge pulls
- **Auto-tracking**: Automatic upstream setup
- **Modern naming**: Uses 'main' as default branch

## 🔧 Customization

### Personal Configuration

**Update User Information:**
```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

**Custom Aliases:**
```bash
# Add to gitconfig [alias] section
myalias = !command here
```

### Work-Specific Settings

**Conditional Configuration:**
```ini
[includeIf "gitdir:~/work/"]
    path = ~/.gitconfig-work

[includeIf "gitdir:~/personal/"]
    path = ~/.gitconfig-personal
```

**Separate Identity:**
```ini
# ~/.gitconfig-work
[user]
    email = work.email@company.com
    signingkey = ~/.ssh/id_work.pub
```

### Organization Integration

**Custom Ignore Patterns:**
```bash
# Add to gitignore
# Company-specific files
*.company-internal
.company-config/
```

**Team Hooks:**
```bash
# Shared hook repository
git config core.hooksPath .githooks
```

## 🧪 Testing & Validation

### Configuration Testing

**Validate Setup:**
```bash
# Test signing
git config --get user.signingkey
ssh-keygen -Y verify -f ~/.ssh/allowed_signers -I user@example.com -n git < test_signature

# Test aliases
git s                             # Should show status
git l                             # Should show log

# Test delta
git diff HEAD~1                   # Should use delta pager
```

**Check Configuration:**
```bash
git config --list                 # Show all configuration
git config --show-origin --list   # Show config sources
```

### Hook Validation

**Test Pre-commit:**
```bash
# Should trigger hooks
echo "test" > test.txt
git add test.txt
git commit -m "test commit"

# Check hook execution
ls -la .git/hooks/
```

### Security Validation

**Verify Signing:**
```bash
git log --show-signature          # Show signature status
gh api user/ssh_signing_keys      # Check GitHub keys
```

**Test Secret Detection:**
```bash
echo "AKIA1234567890123456" > secret.txt
git add secret.txt
git commit -m "test"              # Should be blocked
```

## 🔧 Troubleshooting

### Common Issues

**Signing Problems:**
```bash
# Check SSH agent
ssh-add -l

# Verify key format
cat ~/.ssh/id_rsa.pub

# Test signing
echo "test" | ssh-keygen -Y sign -n git -f ~/.ssh/id_rsa
```

**Delta Not Working:**
```bash
# Check delta installation
which delta

# Manual delta test
echo -e "line1\nline2" | delta
```

**Hooks Not Running:**
```bash
# Check permissions
ls -la .git/hooks/
chmod +x .git/hooks/pre-commit

# Test manually
.git/hooks/pre-commit
```

### Performance Issues

**Large Repository:**
```bash
# Enable maintenance
git maintenance start

# Configure partial clone
git config core.preloadindex true
git config core.fscache true
```

**Slow Operations:**
```bash
# Check repository health
git fsck --full

# Optimize repository
git gc --aggressive
git repack -ad
```

## 🚀 Advanced Features

### Maintenance Configuration

**Automatic Optimization:**
```ini
[maintenance]
    auto = true
    strategy = incremental
```

**Background Tasks:**
- **Garbage collection**: Remove unreachable objects
- **Pack optimization**: Optimize object storage
- **Index updates**: Keep commit graph current

### LFS Integration

**Large File Support:**
```ini
[filter "lfs"]
    clean = git-lfs clean -- %f
    smudge = git-lfs smudge -- %f
    process = git-lfs filter-process
    required = true
```

**Usage:**
```bash
git lfs track "*.psd"             # Track file types
git lfs track "large-file.bin"    # Track specific files
```

---

**Security**: SSH/GPG signing • Secret detection • Object validation
**Features**: Delta diffs • Smart aliases • Modern workflows • GitHub integration
**Performance**: Optimized for large repositories • Background maintenance

*Professional Git configuration for secure, efficient development workflows.*