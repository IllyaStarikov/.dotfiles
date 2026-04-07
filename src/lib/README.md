# ZSH Library System

A small collection of ZSH library modules used by the dotfiles install
scripts and CLI utilities under `src/scripts/`.

## Overview

This directory contains 11 modules. Four are loaded automatically by
`init.zsh` (the "core") and the rest are opt-in via `lib_load <name>`.

## Quick Start

```zsh
# From a script under src/scripts/, src/setup/, etc:
source "$DOTFILES/src/lib/init.zsh"

# init.zsh auto-loads the four core modules: colors, utils, logging, die.
LOG INFO "Hello, world"
require_command git

# Opt-in modules:
lib_load config
config_get themes.json default_theme

lib_load ssh
ssh_key_exists "id_ed25519"
```

## Available Libraries

### Core (auto-loaded by `init.zsh`)

#### colors.zsh

Terminal colors and styling.

```zsh
echo "${RED}Error${NC}"
colorize "Success" "GREEN" "BOLD"
```

#### utils.zsh

OS detection, command checks, file operations.

```zsh
is_macos && brew install foo
is_linux && apt install foo
command_exists git || die "git is required"
trim "  hello  "
```

#### logging.zsh

Structured logging with levels.

```zsh
LOG INFO "Application started"
LOG ERROR "Failed to connect"
LOG DEBUG "x = $x"
```

#### die.zsh

Error handling and exit helpers. See the SECURITY NOTE at the top of
`die.zsh` before using `assert`, `execute_or_die`, or `wait_for_or_die`
— those accept eval'd condition strings and must only be called with
trusted, hard-coded literals.

```zsh
die 1 "Fatal error"
require_command jq
require_file /etc/hosts
```

### Opt-in modules (`lib_load <name>`)

| Module | Purpose |
|--------|---------|
| `callstack` | Stack traces, debug helpers, simple profiler |
| `config`    | JSON config reader (used by install scripts) |
| `help`      | Help text generation |
| `math`      | Arithmetic helpers |
| `ssh`       | SSH key and config helpers |
| `textwrap`  | Text wrapping/centering |
| `unit`      | Lightweight unit-test assertions |

## Dependency Management

`lib.zsh` resolves dependencies automatically. For example,
`lib_load die` pulls in `colors`, `callstack`, and `logging`.

```zsh
lib_show_dependencies     # all
lib_show_dependencies die # just die
```

## Configuration

Environment variables:

- `LIB_DIR` — library directory (auto-detected)
- `LIB_VERBOSE` — print loader messages (`0`/`1`)
- `LIB_STRICT` — fail on missing libraries (`0`/`1`)
- `LIB_AUTOLOAD` — auto-load core modules (`0`/`1`)

## Library Development

### Creating a new library

1. Create `src/lib/mylib.zsh`.
2. Use `lib_<name>_*` or `<lib>_*` function naming.
3. Register dependencies in `lib.zsh::LIB_DEPENDENCIES`.
4. Add a row to the table above.
5. Add a unit test under `test/unit/lib/`.

### Conventions

- Functions are named consistently (snake_case, prefix-grouped).
- Validate inputs at the public boundary.
- Never `eval` user-controlled strings — see `die.zsh`'s SECURITY NOTE.
- Document any function whose behaviour is non-obvious.

## Compatibility

- Requires ZSH 5.0+.
- Some helpers shell out to `jq`, `bc`, or other tools when available.
- Tested on macOS and Linux.

## License

Part of the dotfiles repository — see the main `LICENSE` file.
