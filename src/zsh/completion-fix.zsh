#!/usr/bin/env zsh
#
# completion-fix.zsh
# Fix for completion hanging after command errors
#

# Function to clean up completion state
cleanup_completion() {
    # Reset completion system state
    unset _comp_force_list 2>/dev/null

    # Clear any stuck file descriptors
    exec 2>&2 1>&1

    # Reset ZLE if we're in an interactive shell
    if [[ -o interactive ]] && [[ -n "$ZLE_VERSION" ]]; then
        zle -R 2>/dev/null || true
    fi
}

# Hook that runs after each command
precmd_completion_cleanup() {
    local last_exit=$?

    # Clean up after failed commands
    if [[ $last_exit -ne 0 ]]; then
        cleanup_completion
    fi

    # Kill any hanging background completion processes
    local comp_pids=$(jobs -p 2>/dev/null | xargs ps -p 2>/dev/null | grep -E "compinit|compdump" | awk '{print $1}')
    if [[ -n "$comp_pids" ]]; then
        for pid in $comp_pids; do
            kill -TERM $pid 2>/dev/null
        done
    fi
}

# Add to precmd hooks only if not already added
if [[ -z "${precmd_functions[(r)precmd_completion_cleanup]}" ]]; then
    precmd_functions+=(precmd_completion_cleanup)
fi

# Widget to manually reset completion (Ctrl+Alt+C)
reset-completion() {
    cleanup_completion
    zle reset-prompt
    echo -e "\n\033[32mCompletion system reset\033[0m"
    zle reset-prompt
}
zle -N reset-completion
bindkey '^[c' reset-completion

# Improve completion responsiveness
zstyle ':completion:*' menu select
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$HOME/.cache/zsh/completions"
zstyle ':completion:*' rehash true

# Add timeout for slow completions
zstyle ':completion:*' show-completer false
zstyle ':completion:*' use-compctl false

# Prevent completion from hanging on network operations
zstyle ':completion:*:*:*:*:hosts' command 'echo localhost'
zstyle ':completion:*:*:*:*:users' users

# Handle specific problematic completions
zstyle ':completion:*:(git|git-*):*' tag-order 'common-commands'
zstyle ':completion:*:npm:*' tag-order 'commands'