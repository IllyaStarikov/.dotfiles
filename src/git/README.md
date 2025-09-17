# Git Configuration

Modern Git setup with SSH signing, delta diffs, and security-first defaults.

## Files

- `gitconfig` - Main configuration
- `gitignore` - Global ignore patterns
- `gitmessage` - Commit template
- `gitleaks.toml` - Secret scanning
- `install-git-hooks` - Hook installer
- `pre-commit-hook` - Validation script
- `setup-git-signing` - GPG/SSH setup

## Quick Setup

```bash
./src/git/install-git-hooks        # Install hooks
./src/git/setup-git-signing --ssh  # Configure SSH signing
```

## Key Features

### Minimal Aliases (15 only)

```bash
gs   # status -sb
gl   # log --oneline --graph
ga   # add
gc   # commit
gp   # push
gco  # checkout
```

### SSH Signing (Recommended)

```ini
[gpg]
    format = ssh
[user]
    signingkey = ~/.ssh/id_rsa.pub
```

10x easier than GPG - no key expiration, already have SSH keys.

### Delta Integration

Beautiful side-by-side diffs with syntax highlighting:

```ini
[core]
    pager = delta
[delta]
    side-by-side = true
    line-numbers = true
```

### Security Settings

```ini
[transfer]
    fsckobjects = true  # Validate all objects
[commit]
    gpgsign = true      # Sign all commits
```

## Lessons Learned

**Don't use GPG unless required** - SSH signing simpler, GitHub native.

**Keep aliases minimal** - Had 50+, nobody remembered them.

**Don't hardcode paths** - Hooks check multiple config locations.

**Use zdiff3 for merges** - Shows common ancestor, clearer than diff3.

## Common Issues

**Gitleaks blocking commits**: False positive? Update `.gitleaks.toml`.

**Delta not working**: Install with `brew install git-delta`.

**SSH signing fails**: Run `./setup-git-signing --ssh` to configure.

See [GitHub SSH Signing Docs](https://docs.github.com/en/authentication/managing-commit-signature-verification/telling-git-about-your-signing-key) for more details.
