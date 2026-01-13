#!/usr/bin/env zsh

# types.zsh - Type checking and validation library
# Provides type checking, validation, and conversion functions

# Type definitions
typeset -g TYPE_STRING="string"
typeset -g TYPE_INT="int"
typeset -g TYPE_FLOAT="float"
typeset -g TYPE_BOOL="bool"
typeset -g TYPE_ARRAY="array"
typeset -g TYPE_HASH="hash"
typeset -g TYPE_FUNCTION="function"
typeset -g TYPE_FILE="file"
typeset -g TYPE_DIR="directory"
typeset -g TYPE_PATH="path"
typeset -g TYPE_URL="url"
typeset -g TYPE_EMAIL="email"
typeset -g TYPE_IP="ip"
typeset -g TYPE_DATE="date"
typeset -g TYPE_TIME="time"

# Basic type checking
is_string() {
    [[ -n "$1" ]] || [[ -z "$1" ]]
}

is_int() {
    local value="$1"
    [[ "$value" =~ ^-?[0-9]+$ ]]
}

is_float() {
    local value="$1"
    [[ "$value" =~ ^-?[0-9]+\.?[0-9]*$ ]] || [[ "$value" =~ ^-?\.[0-9]+$ ]]
}

is_number() {
    is_int "$1" || is_float "$1"
}

is_bool() {
    local value="${1,,}"  # lowercase
    [[ "$value" == "true" ]] || [[ "$value" == "false" ]] || \
    [[ "$value" == "1" ]] || [[ "$value" == "0" ]] || \
    [[ "$value" == "yes" ]] || [[ "$value" == "no" ]] || \
    [[ "$value" == "on" ]] || [[ "$value" == "off" ]]
}

is_array() {
    local var_name="$1"
    [[ "${(t)${(P)var_name}}" == *array* ]]
}

is_hash() {
    local var_name="$1"
    [[ "${(t)${(P)var_name}}" == *association* ]]
}

is_function() {
    local name="$1"
    declare -f "$name" >/dev/null 2>&1
}

is_command() {
    local name="$1"
    command -v "$name" >/dev/null 2>&1
}

# File system type checking
is_file() {
    [[ -f "$1" ]]
}

is_dir() {
    [[ -d "$1" ]]
}

is_directory() {
    is_dir "$1"
}

is_link() {
    [[ -L "$1" ]]
}

is_readable() {
    [[ -r "$1" ]]
}

is_writable() {
    [[ -w "$1" ]]
}

is_executable() {
    [[ -x "$1" ]]
}

is_empty_file() {
    [[ -f "$1" ]] && [[ ! -s "$1" ]]
}

is_empty_dir() {
    [[ -d "$1" ]] && [[ -z "$(ls -A "$1" 2>/dev/null)" ]]
}

# Path validation
is_absolute_path() {
    [[ "$1" == /* ]]
}

is_relative_path() {
    [[ "$1" != /* ]]
}

is_valid_path() {
    local path="$1"
    # Check for invalid characters
    [[ ! "$path" =~ [\0] ]]
}

# String validation
is_empty() {
    [[ -z "$1" ]]
}

is_not_empty() {
    [[ -n "$1" ]]
}

is_alpha() {
    [[ "$1" =~ ^[[:alpha:]]+$ ]]
}

is_alnum() {
    [[ "$1" =~ ^[[:alnum:]]+$ ]]
}

is_digit() {
    [[ "$1" =~ ^[[:digit:]]+$ ]]
}

is_upper() {
    [[ "$1" =~ ^[[:upper:]]+$ ]]
}

is_lower() {
    [[ "$1" =~ ^[[:lower:]]+$ ]]
}

is_space() {
    [[ "$1" =~ ^[[:space:]]+$ ]]
}

# Format validation
is_email() {
    local email="$1"
    [[ "$email" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]
}

is_url() {
    local url="$1"
    [[ "$url" =~ ^https?://[a-zA-Z0-9.-]+(:[0-9]+)?(/.*)?$ ]] || \
    [[ "$url" =~ ^ftp://[a-zA-Z0-9.-]+(:[0-9]+)?(/.*)?$ ]]
}

is_ip() {
    is_ipv4 "$1" || is_ipv6 "$1"
}

is_ipv4() {
    local ip="$1"
    local regex='^([0-9]{1,3}\.){3}[0-9]{1,3}$'

    if [[ ! "$ip" =~ $regex ]]; then
        return 1
    fi

    # Check each octet
    local IFS='.'
    local -a octets=($ip)
    for octet in "${octets[@]}"; do
        if [[ $octet -gt 255 ]]; then
            return 1
        fi
    done

    return 0
}

is_ipv6() {
    local ip="$1"
    # Simplified IPv6 check
    [[ "$ip" =~ ^([0-9a-fA-F]{0,4}:){1,7}[0-9a-fA-F]{0,4}$ ]]
}

is_mac_address() {
    local mac="$1"
    [[ "$mac" =~ ^([0-9a-fA-F]{2}:){5}[0-9a-fA-F]{2}$ ]]
}

is_port() {
    local port="$1"
    is_int "$port" && [[ $port -ge 1 ]] && [[ $port -le 65535 ]]
}

is_uuid() {
    local uuid="$1"
    [[ "$uuid" =~ ^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$ ]]
}

is_hex() {
    local hex="$1"
    [[ "$hex" =~ ^[0-9a-fA-F]+$ ]]
}

is_base64() {
    local str="$1"
    [[ "$str" =~ ^[A-Za-z0-9+/]*={0,2}$ ]]
}

# Date/time validation
is_date() {
    local date="$1"
    date -d "$date" >/dev/null 2>&1 || date -j -f "%Y-%m-%d" "$date" >/dev/null 2>&1
}

is_time() {
    local time="$1"
    [[ "$time" =~ ^([01]?[0-9]|2[0-3]):[0-5][0-9](:[0-5][0-9])?$ ]]
}

is_datetime() {
    local datetime="$1"
    # ISO 8601 format
    [[ "$datetime" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}[T\ ][0-9]{2}:[0-9]{2}:[0-9]{2}$ ]]
}

# Range validation
in_range() {
    local value="$1"
    local min="$2"
    local max="$3"

    if is_number "$value" && is_number "$min" && is_number "$max"; then
        (( $(echo "$value >= $min && $value <= $max" | bc -l) ))
    else
        return 1
    fi
}

# Length validation
has_length() {
    local string="$1"
    local length="$2"
    [[ ${#string} -eq $length ]]
}

min_length() {
    local string="$1"
    local min="$2"
    [[ ${#string} -ge $min ]]
}

max_length() {
    local string="$1"
    local max="$2"
    [[ ${#string} -le $max ]]
}

# Type conversion
to_bool() {
    local value="${1,,}"  # lowercase

    case "$value" in
        true|1|yes|on) echo "true" ;;
        false|0|no|off) echo "false" ;;
        *) return 1 ;;
    esac
}

to_int() {
    local value="$1"
    if is_int "$value"; then
        echo "$value"
    elif is_float "$value"; then
        echo "${value%%.*}"
    else
        return 1
    fi
}

to_float() {
    local value="$1"
    if is_number "$value"; then
        printf "%.2f" "$value"
    else
        return 1
    fi
}

to_upper() {
    echo "${1:u}"
}

to_lower() {
    echo "${1:l}"
}

to_title() {
    echo "${(C)1}"
}

# Type coercion with defaults
coerce_string() {
    local value="$1"
    local default="${2:-}"
    echo "${value:-$default}"
}

coerce_int() {
    local value="$1"
    local default="${2:-0}"

    if is_int "$value"; then
        echo "$value"
    else
        echo "$default"
    fi
}

coerce_float() {
    local value="$1"
    local default="${2:-0.0}"

    if is_number "$value"; then
        echo "$value"
    else
        echo "$default"
    fi
}

coerce_bool() {
    local value="$1"
    local default="${2:-false}"

    to_bool "$value" || echo "$default"
}

# Type assertions (fail if not valid)
assert_type() {
    local value="$1"
    local type="$2"
    local message="${3:-Type assertion failed: expected $type}"

    case "$type" in
        string) is_string "$value" || die 1 "$message" ;;
        int) is_int "$value" || die 1 "$message" ;;
        float) is_float "$value" || die 1 "$message" ;;
        number) is_number "$value" || die 1 "$message" ;;
        bool) is_bool "$value" || die 1 "$message" ;;
        array) is_array "$value" || die 1 "$message" ;;
        hash) is_hash "$value" || die 1 "$message" ;;
        function) is_function "$value" || die 1 "$message" ;;
        file) is_file "$value" || die 1 "$message" ;;
        dir|directory) is_dir "$value" || die 1 "$message" ;;
        email) is_email "$value" || die 1 "$message" ;;
        url) is_url "$value" || die 1 "$message" ;;
        ip) is_ip "$value" || die 1 "$message" ;;
        *) die 1 "Unknown type: $type" ;;
    esac
}

# Validation with custom rules
validate() {
    local value="$1"
    shift

    while [[ $# -gt 0 ]]; do
        local rule="$1"
        shift

        case "$rule" in
            required)
                is_not_empty "$value" || return 1
                ;;
            email)
                is_email "$value" || return 1
                ;;
            url)
                is_url "$value" || return 1
                ;;
            ip)
                is_ip "$value" || return 1
                ;;
            int)
                is_int "$value" || return 1
                ;;
            float)
                is_float "$value" || return 1
                ;;
            bool)
                is_bool "$value" || return 1
                ;;
            alpha)
                is_alpha "$value" || return 1
                ;;
            alnum)
                is_alnum "$value" || return 1
                ;;
            min:*)
                local min="${rule#min:}"
                if is_number "$value"; then
                    (( $(echo "$value >= $min" | bc -l) )) || return 1
                else
                    min_length "$value" "$min" || return 1
                fi
                ;;
            max:*)
                local max="${rule#max:}"
                if is_number "$value"; then
                    (( $(echo "$value <= $max" | bc -l) )) || return 1
                else
                    max_length "$value" "$max" || return 1
                fi
                ;;
            len:*)
                local len="${rule#len:}"
                has_length "$value" "$len" || return 1
                ;;
            regex:*)
                local pattern="${rule#regex:}"
                [[ "$value" =~ $pattern ]] || return 1
                ;;
            in:*)
                local options="${rule#in:}"
                local -a valid_options=("${(s:,:)options}")
                local found=0
                for opt in "${valid_options[@]}"; do
                    if [[ "$value" == "$opt" ]]; then
                        found=1
                        break
                    fi
                done
                [[ $found -eq 1 ]] || return 1
                ;;
            *)
                echo "Unknown validation rule: $rule" >&2
                return 1
                ;;
        esac
    done

    return 0
}

# Type inference
infer_type() {
    local value="$1"

    if is_bool "$value"; then
        echo "bool"
    elif is_int "$value"; then
        echo "int"
    elif is_float "$value"; then
        echo "float"
    elif is_email "$value"; then
        echo "email"
    elif is_url "$value"; then
        echo "url"
    elif is_ipv4 "$value"; then
        echo "ipv4"
    elif is_ipv6 "$value"; then
        echo "ipv6"
    elif is_date "$value"; then
        echo "date"
    elif is_time "$value"; then
        echo "time"
    elif is_uuid "$value"; then
        echo "uuid"
    elif is_hex "$value"; then
        echo "hex"
    elif is_base64 "$value"; then
        echo "base64"
    else
        echo "string"
    fi
}

# Schema validation
typeset -gA TYPE_SCHEMAS=()

define_schema() {
    local name="$1"
    local definition="$2"
    TYPE_SCHEMAS[$name]="$definition"
}

validate_schema() {
    local -n data_ref=$1
    local schema_name="$2"

    if [[ -z "${TYPE_SCHEMAS[$schema_name]}" ]]; then
        echo "Schema not found: $schema_name" >&2
        return 1
    fi

    # Parse schema definition
    local schema="${TYPE_SCHEMAS[$schema_name]}"
    local -a rules=("${(s:;:)schema}")

    for rule in "${rules[@]}"; do
        local field="${rule%%:*}"
        local constraints="${rule#*:}"

        if [[ -z "${data_ref[$field]}" ]]; then
            if [[ "$constraints" == *required* ]]; then
                echo "Required field missing: $field" >&2
                return 1
            fi
            continue
        fi

        if ! validate "${data_ref[$field]}" "${(s:,:)constraints}"; then
            echo "Validation failed for field: $field" >&2
            return 1
        fi
    done

    return 0
}

# Custom validators
typeset -gA CUSTOM_VALIDATORS=()

register_validator() {
    local name="$1"
    local function="$2"
    CUSTOM_VALIDATORS[$name]="$function"
}

run_validator() {
    local name="$1"
    local value="$2"

    if [[ -n "${CUSTOM_VALIDATORS[$name]}" ]]; then
        "${CUSTOM_VALIDATORS[$name]}" "$value"
    else
        echo "Validator not found: $name" >&2
        return 1
    fi
}

# Type guards for safer programming
guard_string() {
    local var_name="$1"
    local value="${(P)var_name}"

    if ! is_string "$value"; then
        echo "Type guard failed: $var_name is not a string" >&2
        return 1
    fi
}

guard_int() {
    local var_name="$1"
    local value="${(P)var_name}"

    if ! is_int "$value"; then
        echo "Type guard failed: $var_name is not an integer" >&2
        return 1
    fi
}

guard_array() {
    local var_name="$1"

    if ! is_array "$var_name"; then
        echo "Type guard failed: $var_name is not an array" >&2
        return 1
    fi
}

# Type checking for function parameters
check_params() {
    local func_name="$1"
    shift

    local param_num=1
    while [[ $# -gt 0 ]]; do
        local value="$1"
        local type="$2"
        shift 2

        if ! validate "$value" "$type"; then
            echo "Parameter $param_num of $func_name failed type check (expected $type)" >&2
            return 1
        fi

        ((param_num++))
    done

    return 0
}

# Helper die function if not available
if ! command -v die >/dev/null 2>&1; then
    die() {
        local exit_code="${1:-1}"
        shift
        echo "$*" >&2
        exit "$exit_code"
    }
fi
