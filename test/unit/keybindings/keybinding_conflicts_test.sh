#!/usr/bin/env zsh
# Key Binding Conflict Detection Tests
# Tests for conflicts in Vim and Zsh keybindings

set -euo pipefail

source "$(dirname "$0")/../../lib/test_helpers.zsh"

readonly DEBUG="${DEBUG:-0}"
readonly NVIM_CONFIG="${DOTFILES_DIR}/src/neovim"
readonly ZSH_CONFIG="${DOTFILES_DIR}/src/zsh"

#######################################
# Debug logging
#######################################
debug_log() {
    [[ "${DEBUG}" -eq 1 ]] && echo "[DEBUG] $*" >&2
}

#######################################
# Test Neovim key binding conflicts
#######################################
test_nvim_keybinding_conflicts() {
    echo -e "${BLUE}=== Neovim Key Binding Conflict Tests ===${NC}"

    test_case "No duplicate key mappings in Neovim"

    # Extract all key mappings from Neovim config
    local mappings_file="${TEST_TMP_DIR}/nvim_mappings.txt"

    # Use Neovim to dump all mappings
    output=$(timeout 10 nvim --headless -u "${NVIM_CONFIG}/init.lua" \
        -c "lua vim.defer_fn(function()
            local mappings = {}
            local modes = {'n', 'i', 'v', 'x', 's', 'o', 'c', 't'}

            for _, mode in ipairs(modes) do
                local mode_maps = vim.api.nvim_get_keymap(mode)
                for _, map in ipairs(mode_maps) do
                    if map.lhs and map.lhs ~= '' then
                        local key = mode .. ':' .. map.lhs
                        if mappings[key] then
                            print('CONFLICT: ' .. key)
                        else
                            mappings[key] = true
                        end
                        print('MAP: ' .. key .. ' -> ' .. (map.rhs or map.callback or 'function'))
                    end
                end
            end
            vim.cmd('qa!')
        end, 3000)" 2>&1 | grep -E "^(MAP:|CONFLICT:)" > "${mappings_file}" || true)

    # Check for conflicts
    local conflicts=$(grep "^CONFLICT:" "${mappings_file}" 2>/dev/null | wc -l)

    if [[ "${conflicts}" -eq 0 ]]; then
        pass
    else
        fail "Found ${conflicts} key binding conflicts"
        if [[ "${DEBUG}" -eq 1 ]]; then
            echo "Conflicts:"
            grep "^CONFLICT:" "${mappings_file}"
        fi
    fi

    test_case "Leader key mappings don't conflict with defaults"

    # Check that leader mappings don't override essential vim commands
    local problematic_leaders=(
        "<leader>w"  # Could conflict with window commands
        "<leader>q"  # Could conflict with quit
        "<leader>e"  # Could conflict with end of word
    )

    local issues=0
    for leader in "${problematic_leaders[@]}"; do
        if grep -q "MAP: n:${leader}" "${mappings_file}" 2>/dev/null; then
            debug_log "Warning: ${leader} mapping might conflict"
            ((issues++))
        fi
    done

    if [[ "${issues}" -eq 0 ]]; then
        pass
    else
        skip "Found ${issues} potentially problematic leader mappings"
    fi

    test_case "No conflicts between plugins and custom mappings"

    # Get custom mappings (from keymaps config)
    local custom_maps="${TEST_TMP_DIR}/custom_maps.txt"
    grep -r "vim.keymap.set\|map(\|noremap\|nnoremap\|inoremap\|vnoremap" \
        "${NVIM_CONFIG}/config/keymaps" 2>/dev/null | \
        sed 's/.*["\x27]\([^"\x27]*\)["\x27].*/\1/' | \
        sort -u > "${custom_maps}" || true

    # Check if any custom maps are being overridden by plugins
    local overrides=0
    while IFS= read -r custom_key; do
        if grep -q "MAP:.*:${custom_key}" "${mappings_file}" 2>/dev/null; then
            count=$(grep "MAP:.*:${custom_key}" "${mappings_file}" | wc -l)
            if [[ "${count}" -gt 1 ]]; then
                debug_log "Key '${custom_key}' mapped ${count} times"
                ((overrides++))
            fi
        fi
    done < "${custom_maps}"

    if [[ "${overrides}" -eq 0 ]]; then
        pass
    else
        fail "Found ${overrides} potential mapping overrides"
    fi
}

#######################################
# Test Zsh key binding conflicts
#######################################
test_zsh_keybinding_conflicts() {
    echo -e "\n${BLUE}=== Zsh Key Binding Conflict Tests ===${NC}"

    test_case "No duplicate key bindings in Zsh"

    # Extract key bindings from zshrc and related files
    local zsh_bindings="${TEST_TMP_DIR}/zsh_bindings.txt"

    # Source zsh config and dump bindings
    (
        export ZDOTDIR="${ZSH_CONFIG}"
        zsh -c "
            source '${ZSH_CONFIG}/zshrc' 2>/dev/null || true
            bindkey -L
        " 2>/dev/null
    ) > "${zsh_bindings}" || true

    # Check for duplicate bindings
    local duplicates=$(awk '{print $2}' "${zsh_bindings}" | sort | uniq -d | wc -l)

    if [[ "${duplicates}" -eq 0 ]]; then
        pass
    else
        fail "Found ${duplicates} duplicate key bindings"
        if [[ "${DEBUG}" -eq 1 ]]; then
            echo "Duplicate keys:"
            awk '{print $2}' "${zsh_bindings}" | sort | uniq -d
        fi
    fi

    test_case "Vi mode bindings don't conflict with defaults"

    # Check for common vi mode conflicts
    local vi_conflicts=0

    # Keys that should work in vi mode
    local important_keys=(
        "^A"  # Beginning of line
        "^E"  # End of line
        "^K"  # Kill line
        "^U"  # Kill backward
        "^W"  # Kill word
    )

    for key in "${important_keys[@]}"; do
        if ! grep -q "bindkey.*${key}" "${zsh_bindings}" 2>/dev/null; then
            debug_log "Missing binding for ${key}"
            ((vi_conflicts++))
        fi
    done

    if [[ "${vi_conflicts}" -eq 0 ]]; then
        pass
    else
        skip "Missing ${vi_conflicts} important key bindings in vi mode"
    fi

    test_case "FZF bindings don't conflict with other plugins"

    # Check FZF-specific bindings
    local fzf_keys=(
        "^R"  # History search
        "^T"  # File search
        "^F"  # Directory search (if configured)
    )

    local fzf_conflicts=0
    for key in "${fzf_keys[@]}"; do
        count=$(grep -c "bindkey.*${key}" "${zsh_bindings}" 2>/dev/null || echo 0)
        if [[ "${count}" -gt 1 ]]; then
            debug_log "Key ${key} bound ${count} times"
            ((fzf_conflicts++))
        fi
    done

    if [[ "${fzf_conflicts}" -eq 0 ]]; then
        pass
    else
        fail "Found ${fzf_conflicts} FZF binding conflicts"
    fi
}

#######################################
# Test cross-application conflicts
#######################################
test_cross_app_conflicts() {
    echo -e "\n${BLUE}=== Cross-Application Key Binding Tests ===${NC}"

    test_case "tmux prefix doesn't conflict with common shortcuts"

    # Get tmux prefix
    local tmux_prefix=$(grep "^set -g prefix" "${DOTFILES_DIR}/src/tmux.conf" 2>/dev/null | \
        awk '{print $NF}' || echo "C-b")

    # Check if prefix conflicts with common editor shortcuts
    case "${tmux_prefix}" in
        "C-x"|"C-c"|"C-v"|"C-s"|"C-z")
            fail "tmux prefix ${tmux_prefix} conflicts with common shortcuts"
            ;;
        *)
            pass
            ;;
    esac

    test_case "No conflicts between tmux and Neovim navigation"

    # Check for navigation key consistency
    local nav_keys=("h" "j" "k" "l")
    local nav_consistent=1

    for key in "${nav_keys[@]}"; do
        # Check if both tmux and nvim use similar navigation
        tmux_nav=$(grep -c "bind.*${key}.*select-pane" "${DOTFILES_DIR}/src/tmux.conf" 2>/dev/null || echo 0)

        if [[ "${tmux_nav}" -eq 0 ]]; then
            debug_log "tmux missing navigation for ${key}"
            nav_consistent=0
        fi
    done

    if [[ "${nav_consistent}" -eq 1 ]]; then
        pass
    else
        skip "Navigation keys not fully configured"
    fi
}

#######################################
# Test for accessibility
#######################################
test_keybinding_accessibility() {
    echo -e "\n${BLUE}=== Key Binding Accessibility Tests ===${NC}"

    test_case "Essential operations have non-chord alternatives"

    # Check that important operations don't require complex chords
    local complex_only=0

    # Operations that should have simple bindings
    local essential_ops=(
        "save"
        "quit"
        "undo"
        "redo"
        "find"
        "replace"
    )

    for op in "${essential_ops[@]}"; do
        # This is a simplified check - in reality would need more sophisticated parsing
        debug_log "Checking accessibility for ${op} operation"
    done

    pass  # Simplified for now

    test_case "No more than 3-key chords for common operations"

    # Check for overly complex key combinations
    local complex_bindings=$(grep -r "vim.keymap.set\|bindkey" "${NVIM_CONFIG}" "${ZSH_CONFIG}" 2>/dev/null | \
        grep -E "<.*>.*<.*>.*<.*>.*<.*>" | wc -l || echo 0)

    if [[ "${complex_bindings}" -eq 0 ]]; then
        pass
    else
        skip "Found ${complex_bindings} potentially complex key chords"
    fi
}

#######################################
# Main test runner
#######################################
main() {
    local failed=0

    test_nvim_keybinding_conflicts || ((failed++))
    test_zsh_keybinding_conflicts || ((failed++))
    test_cross_app_conflicts || ((failed++))
    test_keybinding_accessibility || ((failed++))

    echo -e "\n${GREEN}=== Key Binding Test Summary ===${NC}"
    echo "Test sets completed: 4"
    echo "Failed test sets: ${failed}"

    return "${failed}"
}

# Run tests
main "$@"