#!/usr/bin/env zsh
# Smoke Tests: Quick Functionality Verification
# TEST_SIZE: small

source "${TEST_DIR}/lib/framework.zsh"

test_neovim_starts() {
    log "TRACE" "Testing Neovim startup"
    
    local output=$(timeout 3 nvim --headless -c "echo 'test'" -c "qa!" 2>&1)
    local exit_code=$?
    
    if [[ $exit_code -eq 124 ]]; then
        log "ERROR" "Neovim startup timeout"
        return 1
    elif [[ $exit_code -ne 0 ]]; then
        log "ERROR" "Neovim failed to start: $output"
        return 1
    fi
    
    return 0
}

test_zsh_config_loads() {
    log "TRACE" "Testing Zsh configuration loading"
    
    local output=$(zsh -c "source $DOTFILES_DIR/src/zsh/zshrc && echo 'loaded'" 2>&1)
    
    if [[ "$output" != *"loaded"* ]]; then
        log "ERROR" "Zsh configuration failed to load"
        return 1
    fi
    
    return 0
}

test_tmux_config_valid() {
    log "TRACE" "Testing tmux configuration"
    
    if ! command -v tmux >/dev/null 2>&1; then
        log "WARNING" "tmux not installed"
        return 77  # Skip
    fi
    
    local output=$(tmux -f "$DOTFILES_DIR/src/tmux.conf" source-file "$DOTFILES_DIR/src/tmux.conf" 2>&1)
    
    if [[ -n "$output" ]]; then
        log "ERROR" "tmux configuration error: $output"
        return 1
    fi
    
    return 0
}

test_git_config_valid() {
    log "TRACE" "Testing git configuration"
    
    local output=$(git config --file "$DOTFILES_DIR/src/git/gitconfig" --list 2>&1)
    
    if [[ $? -ne 0 ]]; then
        log "ERROR" "Git configuration invalid: $output"
        return 1
    fi
    
    return 0
}

test_theme_switcher_exists() {
    log "TRACE" "Testing theme switcher availability"
    
    local theme_script="$DOTFILES_DIR/src/theme-switcher/switch-theme.sh"
    
    assert_file_exists "$theme_script" "Theme switcher script not found"
    
    if [[ ! -x "$theme_script" ]]; then
        log "ERROR" "Theme switcher not executable"
        return 1
    fi
    
    return 0
}

test_essential_commands() {
    log "TRACE" "Testing essential commands availability"
    
    local -a commands=(git zsh nvim)
    local missing=0
    
    for cmd in "${commands[@]}"; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            log "ERROR" "Essential command not found: $cmd"
            ((missing++))
        fi
    done
    
    [[ $missing -eq 0 ]] || return 1
    return 0
}

test_dotfiles_symlinks() {
    log "TRACE" "Testing dotfiles symlinks"
    
    local broken_links=0
    
    # Check common symlink locations
    local -a common_links=(
        "$HOME/.config/nvim"
        "$HOME/.zshrc"
        "$HOME/.tmux.conf"
        "$HOME/.gitconfig"
    )
    
    for link in "${common_links[@]}"; do
        if [[ -L "$link" ]]; then
            if [[ ! -e "$link" ]]; then
                log "ERROR" "Broken symlink: $link"
                ((broken_links++))
            fi
        fi
    done
    
    [[ $broken_links -eq 0 ]] || return 1
    return 0
}

test_environment_variables() {
    log "TRACE" "Testing environment variables"
    
    # Source the environment and check key variables
    (
        source "$DOTFILES_DIR/src/zsh/zshrc" 2>/dev/null || true
        
        if [[ -z "$EDITOR" ]]; then
            log "WARNING" "EDITOR not set"
        fi
        
        if [[ -z "$PATH" ]]; then
            log "ERROR" "PATH not set"
            return 1
        fi
    )
    
    return $?
}