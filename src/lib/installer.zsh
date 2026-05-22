#!/usr/bin/env zsh
#
# installer.zsh — sha256-verified download + run for third-party
# bootstrap scripts (Homebrew, NVM, Zinit, Starship, Rust, …).
#
# USAGE:
#   lib_load installer
#   installer_run <name> <interpreter> [-- script-args...]
#
# Where <name> matches a top-level key under .installers in
# config/urls.json. The function:
#   1. Reads the URL (and optional sha256) from urls.json.
#   2. Downloads the script to a private tempfile with TLS-min + redirect.
#   3. If a sha256 is configured, verifies the digest before execution.
#      Hash mismatch is a hard failure (exit 1).
#   4. Runs the script through <interpreter> with any trailing args.
#   5. Always cleans up the tempfile.
#
# Falling back to streaming `curl … | sh` would defeat the verification
# (we'd be hashing what we executed, not what we downloaded). The
# materialise-then-exec pattern is the whole point.
#
# Rolling-CDN installers (Rust's sh.rustup.rs, Starship's
# starship.rs/install.sh) configure sha256=null in urls.json. We still
# enforce TLS 1.2+ and `--proto =https`, but cannot hash-verify the
# fetched script because upstream re-renders it dynamically. Pinning
# those would be misleading — and accepted as a known trade-off in the
# May 2026 production-readiness audit (L7 decision).

# Module deps: needs $DOTFILES to find config/urls.json, and a working
# jq for the lookup.
typeset -g INSTALLER_DOTFILES="${DOTFILES:-${DOTFILES_DIR:-$HOME/.dotfiles}}"
typeset -g INSTALLER_URLS_JSON="${INSTALLER_DOTFILES}/config/urls.json"

# Look up a flat key under `.installers` in urls.json. We keep the schema
# flat (URL at .installers.<name>, optional sha at .installers.<name>_sha256)
# so existing get_config callers in install.sh keep working unchanged.
_installer_lookup() {
  local key="$1"
  if ! command -v jq >/dev/null 2>&1; then
    echo "installer.zsh: jq is required to read urls.json" >&2
    return 1
  fi
  jq -r --arg key "$key" '.installers[$key] // empty' "$INSTALLER_URLS_JSON"
}

# Download to a tempfile with secure-transport flags.
_installer_fetch() {
  local url="$1" dest="$2"
  curl --proto '=https' --tlsv1.2 --fail --show-error --silent --location \
    --retry 3 --max-time 60 \
    --output "$dest" \
    "$url"
}

# Verify file matches sha256. Returns 0 on match, 1 on mismatch.
_installer_verify_sha() {
  local file="$1" expected="$2"
  local actual
  if command -v shasum >/dev/null 2>&1; then
    actual="$(shasum -a 256 "$file" | awk '{print $1}')"
  elif command -v sha256sum >/dev/null 2>&1; then
    actual="$(sha256sum "$file" | awk '{print $1}')"
  else
    echo "installer.zsh: no shasum/sha256sum on PATH" >&2
    return 1
  fi
  if [[ "$actual" != "$expected" ]]; then
    echo "installer.zsh: sha256 mismatch" >&2
    echo "    expected: $expected" >&2
    echo "    actual:   $actual" >&2
    return 1
  fi
}

# Public entrypoint.
#   installer_run <name> <interpreter> [-- script-args...]
# Example:
#   installer_run homebrew "/bin/bash"
#   installer_run nvm bash
#   installer_run starship sh -- -y
installer_run() {
  local name="$1"; shift || return 1
  local interpreter="$1"; shift || return 1
  local -a script_args
  if [[ "${1:-}" == "--" ]]; then
    shift
    script_args=("$@")
  else
    script_args=("$@")
  fi

  local url sha
  url="$(_installer_lookup "$name")"
  sha="$(_installer_lookup "${name}_sha256")"
  # Treat literal "null" (from `null` JSON) as missing — rolling-CDN entries.
  [[ "$sha" == "null" ]] && sha=""

  if [[ -z "$url" ]]; then
    echo "installer.zsh: no URL configured for '$name' in $INSTALLER_URLS_JSON" >&2
    return 1
  fi

  local tmp
  tmp="$(mktemp -t "dotfiles-installer-${name}.XXXXXX")"
  # Always clean up on return.
  trap "rm -f '$tmp'" EXIT INT TERM

  if ! _installer_fetch "$url" "$tmp"; then
    echo "installer.zsh: failed to download $url" >&2
    return 1
  fi

  if [[ -n "$sha" ]]; then
    if ! _installer_verify_sha "$tmp" "$sha"; then
      return 1
    fi
    echo "installer.zsh: sha256 verified for '$name'"
  else
    echo "installer.zsh: '$name' has no configured sha256 (rolling CDN — TLS-min enforced)"
  fi

  # Execute. We pass the script via path argument, not stdin, so the
  # interpreter can read $0 correctly.
  "$interpreter" "$tmp" "${script_args[@]}"
}
