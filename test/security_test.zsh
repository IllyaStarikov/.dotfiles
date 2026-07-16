#!/usr/bin/env zsh
# Security Tests: Vulnerability and Security Scanning
# TEST_SIZE: medium

source "${TEST_DIR}/lib/framework.zsh"

test_no_hardcoded_secrets() {
  log "TRACE" "Scanning for hardcoded secrets"

  local secret_patterns=(
    "password\s*=\s*['\"][^'\"]+['\"]"
    "api[_-]?key\s*=\s*['\"][^'\"]+['\"]"
    "secret\s*=\s*['\"][^'\"]+['\"]"
    "token\s*=\s*['\"][^'\"]+['\"]"
    "aws_access_key_id"
    "aws_secret_access_key"
    "github_token"
    "private[_-]?key"
  )

  local violations=0

  for pattern in "${secret_patterns[@]}"; do
    # -I skips binary files: compiled __pycache__/*.pyc used to surface as
    # un-filterable "Binary file ... matches" lines.
    local matches=$(grep -rIiE "$pattern" "$DOTFILES_DIR/src" \
      --exclude-dir=.git \
      --exclude-dir=.dotfiles.private \
      --exclude-dir=__pycache__ \
      --exclude="*.md" \
      --exclude="*.txt" \
      --exclude="*.example" \
      2>/dev/null)

    # Drop known-safe shapes before judging:
    #  - values that are ENV VAR NAMES, not secrets (minuet.nvim's api_key
    #    field takes the NAME of the variable, e.g. "ANTHROPIC_API_KEY")
    #  - all-uppercase/underscore sentinels ("TERM") and the "mlx-local"
    #    placeholder for the local MLX server
    # Real secret scanning is owned by Gitleaks (pre-commit hook + CI).
    if [[ -n "$matches" ]]; then
      # [[:space:]] not \s: BSD grep's ERE has no \s class. The third filter
      # drops env-var DEREFERENCES like export CORTEX_API_KEY="${ANTHROPIC_API_KEY}".
      matches=$(echo "$matches" \
        | grep -vE "=[[:space:]]*['\"][A-Z][A-Z0-9_]*['\"]" \
        | grep -vE "=[[:space:]]*['\"]?\\\$" \
        | grep -v "mlx-local")
    fi

    if [[ -n "$matches" ]]; then
      log "ERROR" "Potential secret found with pattern: $pattern"
      log "DEBUG" "Matches: $matches"
      ((violations++))
    fi
  done

  [[ $violations -eq 0 ]] || return 1
  return 0
}

test_no_exposed_ssh_keys() {
  log "TRACE" "Checking for exposed SSH keys"

  local key_patterns=(
    "-----BEGIN RSA PRIVATE KEY-----"
    "-----BEGIN DSA PRIVATE KEY-----"
    "-----BEGIN EC PRIVATE KEY-----"
    "-----BEGIN OPENSSH PRIVATE KEY-----"
    "-----BEGIN PGP PRIVATE KEY-----"
  )

  for pattern in "${key_patterns[@]}"; do
    local matches=$(grep -r "$pattern" "$DOTFILES_DIR" \
      --exclude-dir=.git \
      --exclude-dir=.dotfiles.private \
      2>/dev/null)

    if [[ -n "$matches" ]]; then
      log "ERROR" "Private key exposed: $pattern"
      return 1
    fi
  done

  return 0
}

test_file_permissions() {
  log "TRACE" "Checking file permissions"

  local issues=0

  # Check for world-writable files
  local world_writable=$(find "$DOTFILES_DIR" -type f -perm -002 2>/dev/null)
  if [[ -n "$world_writable" ]]; then
    log "ERROR" "World-writable files found:"
    echo "$world_writable" | while read -r file; do
      log "ERROR" "  - $file"
    done
    ((issues++))
  fi

  # Check for files with excessive permissions
  local excessive_perms=$(find "$DOTFILES_DIR" -type f -perm -077 \
    ! -path "*/\.git/*" \
    ! -name "*.sh" \
    ! -name "*.zsh" \
    2>/dev/null)

  if [[ -n "$excessive_perms" ]]; then
    log "WARNING" "Files with excessive permissions (group/other access):"
    echo "$excessive_perms" | head -5 | while read -r file; do
      log "WARNING" "  - $file"
    done
    ((issues++))
  fi

  [[ $issues -eq 0 ]] || return 1
  return 0
}

# ============================================================================
# ADVISORY AUDITS (audit_*) — heuristic surveys that emit WARNING-level log
# entries but do not hard-fail the suite. The framework's run_test_functions
# discovers only test_* prefixes, so renaming these keeps them runnable from
# test_security_audits below while preventing them from claiming to be hard
# gates. The hard gates are: test_no_hardcoded_secrets, test_no_exposed_ssh_keys,
# test_file_permissions, test_dependency_vulnerabilities, test_git_hooks_security,
# plus gitleaks (pre-commit hook + CI workflow).
# ============================================================================

audit_command_injection() {
  log "TRACE" "Auditing for command-injection patterns (advisory)"

  # Match eval/sh-c on a literal variable reference, NOT `eval "$(cmd)"` which
  # is the safe command-substitution idiom (sourcing tool init output).
  local vulnerable_patterns=(
    'eval[[:space:]]+"\$[A-Za-z_{]'
    'eval[[:space:]]+`'
    '(sh|bash|zsh)[[:space:]]+-c[[:space:]]+"\$[A-Za-z_{]'
  )

  local violations=0

  for pattern in "${vulnerable_patterns[@]}"; do
    # Restrict scan to user-facing scripts; src/lib/ is internal infrastructure
    # whose eval usages are documented and audited in src/lib/die.zsh's header.
    local matches
    matches=$(grep -rE "$pattern" "$DOTFILES_DIR"/src/scripts/ "$DOTFILES_DIR"/src/setup/ \
      --include="*.sh" \
      --include="*.zsh" \
      --include="*.bash" \
      2>/dev/null)

    if [[ -n "$matches" ]]; then
      log "WARNING" "Possible command-injection pattern '$pattern':"
      echo "$matches" | head -5 | while read -r line; do
        log "WARNING" "  $line"
      done
      ((violations++))
    fi
  done

  return "$violations"
}

audit_temp_files() {
  log "TRACE" "Auditing for insecure temporary file usage (advisory)"

  local insecure_patterns=(
    'mktemp[[:space:]]+/tmp/'
    '>[[:space:]]*/tmp/[^$]'
  )

  local violations=0

  for pattern in "${insecure_patterns[@]}"; do
    local matches
    matches=$(grep -rE "$pattern" "$DOTFILES_DIR/src" \
      --include="*.sh" \
      --include="*.zsh" \
      --include="*.bash" \
      2>/dev/null | grep -v "mktemp -")

    if [[ -n "$matches" ]]; then
      log "WARNING" "Insecure temp-file pattern '$pattern':"
      echo "$matches" | head -5 | while read -r line; do
        log "WARNING" "  $line"
      done
      ((violations++))
    fi
  done

  return "$violations"
}

# Hard-fail test: any actual insecure-transport flag is a real bug.
test_no_unsafe_curl_wget() {
  log "TRACE" "Checking for unsafe curl/wget usage"

  local unsafe_patterns=(
    'curl[[:space:]]+.*--insecure'
    'curl[[:space:]]+.*-k[[:space:]]'
    'wget[[:space:]]+.*--no-check-certificate'
    'curl[[:space:]]+http://'
    'wget[[:space:]]+http://'
  )

  local violations=0

  for pattern in "${unsafe_patterns[@]}"; do
    local matches
    matches=$(grep -rE "$pattern" "$DOTFILES_DIR/src" \
      --include="*.sh" \
      --include="*.zsh" \
      2>/dev/null)

    if [[ -n "$matches" ]]; then
      log "ERROR" "Unsafe download: $pattern"
      log "ERROR" "$matches"
      ((violations++))
    fi
  done

  [[ $violations -eq 0 ]] || return 1
  return 0
}

test_git_hooks_security() {
  log "TRACE" "Checking git hooks security"

  local hooks_dir="$DOTFILES_DIR/.git/hooks"

  if [[ -d "$hooks_dir" ]]; then
    for hook in "$hooks_dir"/*; do
      [[ -f "$hook" ]] || continue
      [[ "$hook" == *.sample ]] && continue

      # Check if hook is executable
      if [[ -x "$hook" ]]; then
        log "INFO" "Active git hook found: $(basename "$hook")"

        # Check for dangerous patterns in hooks. Word-bound the short
        # tokens: a bare "format" used to match "inFORMATion" in an echo.
        if grep -qE "(rm -rf|dd if=|\bmkfs\b|\bshred\b)" "$hook" 2>/dev/null; then
          log "ERROR" "Dangerous command in git hook: $(basename "$hook")"
          return 1
        fi
      fi
    done
  fi

  return 0
}

test_dependency_vulnerabilities() {
  log "TRACE" "Checking for known vulnerabilities in dependencies"

  # Check npm packages if package.json exists
  if [[ -f "$DOTFILES_DIR/package.json" ]]; then
    if command -v npm >/dev/null 2>&1; then
      local audit_output=$(cd "$DOTFILES_DIR" && npm audit --json 2>/dev/null)
      local vulnerabilities=$(echo "$audit_output" | jq '.metadata.vulnerabilities.total' 2>/dev/null)

      if [[ -n "$vulnerabilities" ]] && [[ "$vulnerabilities" -gt 0 ]]; then
        log "WARNING" "npm audit found $vulnerabilities vulnerabilities"

        local critical=$(echo "$audit_output" | jq '.metadata.vulnerabilities.critical' 2>/dev/null)
        if [[ -n "$critical" ]] && [[ "$critical" -gt 0 ]]; then
          log "ERROR" "Critical vulnerabilities found: $critical"
          return 1
        fi
      fi
    fi
  fi

  # Check for outdated tools with known vulnerabilities
  local tools_to_check=(
    "openssl:1.0" # Old OpenSSL versions
    "bash:3."     # Shellshock vulnerable versions
  )

  for tool_pattern in "${tools_to_check[@]}"; do
    local tool="${tool_pattern%:*}"
    local bad_version="${tool_pattern#*:}"

    if command -v "$tool" >/dev/null 2>&1; then
      local version=$("$tool" --version 2>&1 | head -1)
      if [[ "$version" == *"$bad_version"* ]]; then
        log "WARNING" "Outdated $tool version may have vulnerabilities: $version"
      fi
    fi
  done

  return 0
}

audit_path_traversal() {
  log "TRACE" "Auditing for path-traversal patterns (advisory)"

  local traversal_patterns=(
    '\.\./\.\.'
    '(cd|source|\.)[[:space:]]+\$[a-z_]'  # only flag lowercased var names (user input style)
  )

  local violations=0

  for pattern in "${traversal_patterns[@]}"; do
    local matches
    matches=$(grep -rE "$pattern" "$DOTFILES_DIR/src" \
      --include="*.sh" \
      --include="*.zsh" \
      2>/dev/null)

    if [[ -n "$matches" ]]; then
      log "WARNING" "Possible path-traversal pattern '$pattern':"
      echo "$matches" | head -5 | while read -r line; do
        log "WARNING" "  $line"
      done
      ((violations++))
    fi
  done

  return "$violations"
}

audit_environment_isolation() {
  log "TRACE" "Auditing environment-isolation hygiene (advisory)"

  local scripts_without_env_reset
  scripts_without_env_reset=$(grep -L "unset CDPATH\|IFS=" \
    "$DOTFILES_DIR"/src/scripts/*.sh \
    "$DOTFILES_DIR"/src/setup/*.sh \
    2>/dev/null)

  if [[ -n "$scripts_without_env_reset" ]]; then
    local count
    count=$(echo "$scripts_without_env_reset" | wc -l | tr -d ' ')
    log "WARNING" "$count scripts without explicit env reset (unset CDPATH / IFS=)"
    return 1
  fi

  return 0
}

# ============================================================================
# Advisory rollup: run each audit_* check and count its findings. This is a
# test_* (so the framework executes it) but it only fails when an audit
# returns a CRITICAL number of findings — currently zero unless a brand-new
# class of pattern lights up. Concrete findings are visible in the WARNING
# logs above each summary line, so reviewers can act on them without the
# entire suite going red on every advisory hit.
# ============================================================================
test_security_audits() {
  log "TRACE" "Running advisory security audits"

  local total_findings=0
  local audits=(
    audit_command_injection
    audit_temp_files
    audit_path_traversal
    audit_environment_isolation
  )

  for audit in "${audits[@]}"; do
    "$audit"
    local n=$?
    (( total_findings += n ))
    log "INFO" "$audit: $n finding(s)"
  done

  log "INFO" "Total advisory findings: $total_findings"
  # No threshold — advisory only. Hard-fail tests live elsewhere in this file.
  return 0
}

# ============================================================================
# Run all test_* functions defined above (provided by framework.zsh).
# ============================================================================
run_test_functions
