#!/usr/bin/env zsh
#
# completion-fix.zsh - ZLE state recovery after command failures
# Fixes autocomplete/autosuggestion unresponsiveness after errors
#
# The key insight: precmd runs BEFORE ZLE is active, so you can't call zle
# commands from precmd. Use zle-line-init which runs when ZLE starts.
#

# Guard against multiple sourcing
(( ${+_COMPLETION_FIX_LOADED} )) && return
typeset -g _COMPLETION_FIX_LOADED=1

# Track last command status for zle-line-init
typeset -g _LAST_CMD_FAILED=0

# ============================================================================
# Core Cleanup Functions
# ============================================================================

# Cancel any pending async autosuggestion requests
# Safe to call from any context (doesn't require ZLE)
_cancel_async_autosuggest() {
  if [[ -n "${_ZSH_AUTOSUGGEST_ASYNC_FD:-}" ]]; then
    zle -F "$_ZSH_AUTOSUGGEST_ASYNC_FD" 2>/dev/null
    exec {_ZSH_AUTOSUGGEST_ASYNC_FD}<&- 2>/dev/null
    unset _ZSH_AUTOSUGGEST_ASYNC_FD
  fi

  if [[ -n "${_ZSH_AUTOSUGGEST_CHILD_PID:-}" ]]; then
    kill -TERM "$_ZSH_AUTOSUGGEST_CHILD_PID" 2>/dev/null
    unset _ZSH_AUTOSUGGEST_CHILD_PID
  fi
}

# Reset ZLE display state (call only when ZLE is active)
_reset_zle_display_state() {
  # Clear autosuggestion display
  POSTDISPLAY=

  # Clear highlight tracking
  unset _ZSH_AUTOSUGGEST_LAST_HIGHLIGHT 2>/dev/null

  # Remove autosuggestion entries from region_highlight
  # Keep syntax highlighting, remove dim autosuggestion entries
  if (( ${#region_highlight[@]} > 0 )); then
    local -a new_highlights=()
    local entry
    for entry in "${region_highlight[@]}"; do
      [[ "$entry" != *"${ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE:-fg=8}"* ]] && \
        new_highlights+=("$entry")
    done
    region_highlight=("${new_highlights[@]}")
  fi
}

# Full ZLE recovery (call only from ZLE widget context)
_full_zle_recovery() {
  _cancel_async_autosuggest
  _reset_zle_display_state

  # Trigger fresh autosuggestion if buffer has content
  if (( ${#BUFFER} > 0 )) && (( ${+functions[_zsh_autosuggest_fetch]} )); then
    _zsh_autosuggest_fetch
  fi
}

# ============================================================================
# Hook: precmd - runs after command, before prompt (NO ZLE context)
# ============================================================================

_precmd_zle_state_prep() {
  local exit_status=$?

  if (( exit_status != 0 )); then
    _LAST_CMD_FAILED=1
    _cancel_async_autosuggest
  else
    _LAST_CMD_FAILED=0
  fi
}

# ============================================================================
# Hook: zle-line-init - runs when ZLE starts reading input (HAS ZLE context)
# ============================================================================

_zle_line_init_recovery() {
  if (( _LAST_CMD_FAILED )); then
    _full_zle_recovery
    _LAST_CMD_FAILED=0
  fi
}

# ============================================================================
# Hook: TRAPINT - handles Ctrl+C
# ============================================================================

_completion_fix_TRAPINT() {
  _cancel_async_autosuggest

  # If ZLE is active, reset display state
  if zle 2>/dev/null; then
    _reset_zle_display_state
    zle -R
  fi

  # Return 128 + signal number to indicate interrupt
  return $(( 128 + $1 ))
}

# ============================================================================
# Manual Reset Widget (fallback for stuck states)
# ============================================================================

_manual_zle_reset() {
  _full_zle_recovery
  zle reset-prompt
  zle -M "ZLE state reset"
}

# ============================================================================
# Registration
# ============================================================================

# Register precmd hook (prepend for early execution)
if [[ -z "${precmd_functions[(r)_precmd_zle_state_prep]}" ]]; then
  precmd_functions=(_precmd_zle_state_prep "${precmd_functions[@]}")
fi

# Register zle-line-init hook (chain with existing if present)
if (( ${+widgets[zle-line-init]} )); then
  local _existing=${widgets[zle-line-init]#user:}
  if [[ -n "$_existing" && "$_existing" != "_zle_line_init_wrapper" ]]; then
    eval "_preserved_zle_line_init() { $_existing \"\$@\" }"
    _zle_line_init_wrapper() {
      _zle_line_init_recovery
      _preserved_zle_line_init "$@"
    }
    zle -N zle-line-init _zle_line_init_wrapper
  fi
else
  zle -N zle-line-init _zle_line_init_recovery
fi

# Register TRAPINT (chain with existing if present)
if (( ${+functions[TRAPINT]} )); then
  functions[_preserved_TRAPINT]=$functions[TRAPINT]
  TRAPINT() {
    _completion_fix_TRAPINT "$@"
    local ret=$?
    _preserved_TRAPINT "$@" 2>/dev/null
    return $ret
  }
else
  TRAPINT() { _completion_fix_TRAPINT "$@" }
fi

# Register manual reset widget
zle -N reset-completion _manual_zle_reset
bindkey '^[c' reset-completion  # Alt+C (fallback)

# ============================================================================
# Completion zstyles
# ============================================================================

zstyle ':completion:*' menu select
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/completions"
zstyle ':completion:*' rehash true

# Prevent slow network completions
zstyle ':completion:*:*:*:*:hosts' command 'echo localhost'
zstyle ':completion:*:*:*:*:users' users

# Limit slow completions
zstyle ':completion:*:(git|git-*):*' tag-order 'common-commands'
zstyle ':completion:*:npm:*' tag-order 'commands'
