#!/usr/bin/env zsh

# cli.zsh - Command line argument parsing library
# Provides comprehensive flag parsing, subcommands, and help generation

# Global variables for parsed arguments
typeset -gA CLI_FLAGS=()
typeset -ga CLI_ARGS=()
typeset -g CLI_COMMAND=""
typeset -gA CLI_OPTIONS=()
typeset -gA CLI_DESCRIPTIONS=()
typeset -gA CLI_DEFAULTS=()
typeset -gA CLI_REQUIRED=()
typeset -gA CLI_TYPES=()
typeset -ga CLI_COMMANDS=()
typeset -gA CLI_COMMAND_DESCRIPTIONS=()
typeset -g CLI_PROGRAM_NAME="${0:t}"
typeset -g CLI_PROGRAM_DESCRIPTION=""
typeset -g CLI_PROGRAM_VERSION="1.0.0"

# Define a flag
cli_flag() {
    local name="$1"
    local short="${2:-}"
    local description="${3:-}"
    local default="${4:-}"
    local type="${5:-string}"  # string, bool, int, float, array
    local required="${6:-false}"

    CLI_OPTIONS[$name]="$short"
    CLI_DESCRIPTIONS[$name]="$description"
    CLI_DEFAULTS[$name]="$default"
    CLI_TYPES[$name]="$type"
    CLI_REQUIRED[$name]="$required"

    # Set default value
    if [[ "$type" == "bool" ]]; then
        CLI_FLAGS[$name]="${default:-false}"
    elif [[ "$type" == "array" ]]; then
        CLI_FLAGS[$name]=""
    else
        CLI_FLAGS[$name]="$default"
    fi
}

# Define a subcommand
cli_command() {
    local name="$1"
    local description="${2:-}"

    CLI_COMMANDS+=("$name")
    CLI_COMMAND_DESCRIPTIONS[$name]="$description"
}

# Set program info
cli_program() {
    CLI_PROGRAM_NAME="${1:-$CLI_PROGRAM_NAME}"
    CLI_PROGRAM_DESCRIPTION="${2:-}"
    CLI_PROGRAM_VERSION="${3:-$CLI_PROGRAM_VERSION}"
}

# Parse command line arguments
cli_parse() {
    local args=("$@")
    local i=0
    local parsing_flags=1

    while [[ $i -lt ${#args[@]} ]]; do
        local arg="${args[$i]}"

        # Check for end of flags
        if [[ "$arg" == "--" ]]; then
            parsing_flags=0
            ((i++))
            continue
        fi

        # Check for subcommand
        if [[ $parsing_flags -eq 1 ]] && [[ -z "$CLI_COMMAND" ]] && [[ "${arg:0:1}" != "-" ]]; then
            if array_contains "$arg" "${CLI_COMMANDS[@]}"; then
                CLI_COMMAND="$arg"
                ((i++))
                continue
            fi
        fi

        # Parse flags
        if [[ $parsing_flags -eq 1 ]] && [[ "${arg:0:1}" == "-" ]]; then
            if [[ "${arg:0:2}" == "--" ]]; then
                # Long flag
                local flag_name="${arg:2}"
                local flag_value=""

                # Check for = syntax
                if [[ "$flag_name" == *"="* ]]; then
                    flag_value="${flag_name#*=}"
                    flag_name="${flag_name%%=*}"
                fi

                if ! _cli_process_flag "$flag_name" "$flag_value" args $i; then
                    echo "Unknown flag: --$flag_name" >&2
                    return 1
                fi
            elif [[ "${arg:0:1}" == "-" ]] && [[ "${#arg}" -gt 1 ]]; then
                # Short flag(s)
                local short_flags="${arg:1}"
                local j
                for ((j=0; j<${#short_flags}; j++)); do
                    local short_flag="${short_flags:$j:1}"
                    local flag_name=$(_cli_find_flag_by_short "$short_flag")

                    if [[ -z "$flag_name" ]]; then
                        echo "Unknown flag: -$short_flag" >&2
                        return 1
                    fi

                    # Last short flag can have a value
                    if [[ $j -eq $((${#short_flags} - 1)) ]]; then
                        if ! _cli_process_flag "$flag_name" "" args $i; then
                            return 1
                        fi
                    else
                        # Boolean flag
                        CLI_FLAGS[$flag_name]="true"
                    fi
                done
            fi
        else
            # Regular argument
            CLI_ARGS+=("$arg")
        fi

        ((i++))
    done

    # Check required flags
    for flag in ${(k)CLI_REQUIRED}; do
        if [[ "${CLI_REQUIRED[$flag]}" == "true" ]] && [[ -z "${CLI_FLAGS[$flag]}" ]]; then
            echo "Required flag missing: --$flag" >&2
            return 1
        fi
    done

    return 0
}

# Process a flag
_cli_process_flag() {
    local flag_name="$1"
    local flag_value="$2"
    local -n args_ref=$3
    local current_index=$4

    # Check if flag exists
    if [[ -z "${CLI_TYPES[$flag_name]}" ]]; then
        return 1
    fi

    local type="${CLI_TYPES[$flag_name]}"

    case "$type" in
        bool)
            CLI_FLAGS[$flag_name]="true"
            ;;
        string|int|float)
            if [[ -z "$flag_value" ]]; then
                # Get next argument as value
                if [[ $((current_index + 1)) -lt ${#args_ref[@]} ]]; then
                    ((current_index++))
                    flag_value="${args_ref[$current_index]}"
                else
                    echo "Flag --$flag_name requires a value" >&2
                    return 1
                fi
            fi

            # Validate type
            if [[ "$type" == "int" ]] && ! [[ "$flag_value" =~ ^-?[0-9]+$ ]]; then
                echo "Flag --$flag_name requires an integer value" >&2
                return 1
            elif [[ "$type" == "float" ]] && ! [[ "$flag_value" =~ ^-?[0-9]+\.?[0-9]*$ ]]; then
                echo "Flag --$flag_name requires a numeric value" >&2
                return 1
            fi

            CLI_FLAGS[$flag_name]="$flag_value"
            ;;
        array)
            if [[ -z "$flag_value" ]]; then
                if [[ $((current_index + 1)) -lt ${#args_ref[@]} ]]; then
                    ((current_index++))
                    flag_value="${args_ref[$current_index]}"
                else
                    echo "Flag --$flag_name requires a value" >&2
                    return 1
                fi
            fi

            if [[ -n "${CLI_FLAGS[$flag_name]}" ]]; then
                CLI_FLAGS[$flag_name]="${CLI_FLAGS[$flag_name]}:$flag_value"
            else
                CLI_FLAGS[$flag_name]="$flag_value"
            fi
            ;;
    esac

    return 0
}

# Find flag name by short option
_cli_find_flag_by_short() {
    local short="$1"

    for flag in ${(k)CLI_OPTIONS}; do
        if [[ "${CLI_OPTIONS[$flag]}" == "$short" ]]; then
            echo "$flag"
            return 0
        fi
    done

    return 1
}

# Get flag value
cli_get() {
    local flag_name="$1"
    local default="${2:-}"

    if [[ -n "${CLI_FLAGS[$flag_name]}" ]]; then
        echo "${CLI_FLAGS[$flag_name]}"
    else
        echo "$default"
    fi
}

# Get array flag values
cli_get_array() {
    local flag_name="$1"
    local values="${CLI_FLAGS[$flag_name]}"

    if [[ -n "$values" ]]; then
        echo "${values//:/ }"
    fi
}

# Check if flag is set
cli_has() {
    local flag_name="$1"
    [[ -n "${CLI_FLAGS[$flag_name]}" ]] && [[ "${CLI_FLAGS[$flag_name]}" != "false" ]]
}

# Get positional arguments
cli_args() {
    echo "${CLI_ARGS[@]}"
}

# Get specific positional argument
cli_arg() {
    local index="$1"
    local default="${2:-}"

    if [[ $index -lt ${#CLI_ARGS[@]} ]]; then
        echo "${CLI_ARGS[$index]}"
    else
        echo "$default"
    fi
}

# Get number of positional arguments
cli_arg_count() {
    echo "${#CLI_ARGS[@]}"
}

# Get current command
cli_command() {
    echo "$CLI_COMMAND"
}

# Generate help text
cli_help() {
    local cmd="${1:-}"

    echo "$CLI_PROGRAM_NAME - $CLI_PROGRAM_DESCRIPTION"
    echo
    echo "Version: $CLI_PROGRAM_VERSION"
    echo
    echo "Usage:"

    if [[ ${#CLI_COMMANDS[@]} -gt 0 ]]; then
        echo "  $CLI_PROGRAM_NAME [OPTIONS] COMMAND [ARGS...]"
        echo
        echo "Commands:"
        for command in "${CLI_COMMANDS[@]}"; do
            printf "  %-20s %s\n" "$command" "${CLI_COMMAND_DESCRIPTIONS[$command]}"
        done
    else
        echo "  $CLI_PROGRAM_NAME [OPTIONS] [ARGS...]"
    fi

    echo
    echo "Options:"

    # Add help flag
    printf "  %-30s %s\n" "-h, --help" "Show this help message"

    # Add version flag
    printf "  %-30s %s\n" "-v, --version" "Show version information"

    # Add defined flags
    for flag in ${(k)CLI_DESCRIPTIONS}; do
        local short="${CLI_OPTIONS[$flag]}"
        local desc="${CLI_DESCRIPTIONS[$flag]}"
        local type="${CLI_TYPES[$flag]}"
        local required="${CLI_REQUIRED[$flag]}"
        local default="${CLI_DEFAULTS[$flag]}"

        local flag_str=""
        if [[ -n "$short" ]]; then
            flag_str="-$short, --$flag"
        else
            flag_str="    --$flag"
        fi

        if [[ "$type" != "bool" ]]; then
            flag_str="$flag_str <$type>"
        fi

        if [[ "$required" == "true" ]]; then
            desc="$desc (required)"
        elif [[ -n "$default" ]] && [[ "$type" != "bool" ]]; then
            desc="$desc (default: $default)"
        fi

        printf "  %-30s %s\n" "$flag_str" "$desc"
    done
}

# Parse with automatic help and version handling
cli_parse_with_help() {
    # Add automatic help and version flags
    cli_flag "help" "h" "Show help message" "" "bool"
    cli_flag "version" "v" "Show version" "" "bool"

    # Parse arguments
    if ! cli_parse "$@"; then
        cli_help
        return 1
    fi

    # Check for help flag
    if cli_has "help"; then
        cli_help
        return 2
    fi

    # Check for version flag
    if cli_has "version"; then
        echo "$CLI_PROGRAM_NAME version $CLI_PROGRAM_VERSION"
        return 2
    fi

    return 0
}

# Reset CLI state
cli_reset() {
    CLI_FLAGS=()
    CLI_ARGS=()
    CLI_COMMAND=""
    CLI_OPTIONS=()
    CLI_DESCRIPTIONS=()
    CLI_DEFAULTS=()
    CLI_REQUIRED=()
    CLI_TYPES=()
    CLI_COMMANDS=()
    CLI_COMMAND_DESCRIPTIONS=()
}

# Helper to check if array contains element
array_contains() {
    local needle="$1"
    shift
    local item
    for item in "$@"; do
        [[ "$item" == "$needle" ]] && return 0
    done
    return 1
}