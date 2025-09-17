#!/usr/bin/env zsh

# hash.zsh - Hash/dictionary operations library
# Provides comprehensive associative array handling functions

# Hash creation and initialization
hash_new() {
    local -n hash_ref=$1
    shift

    hash_ref=()
    while [[ $# -gt 0 ]]; do
        local key="$1"
        local value="$2"
        hash_ref[$key]="$value"
        shift 2
    done
}

hash_from_arrays() {
    local -n hash_ref=$1
    local -n keys_ref=$2
    local -n values_ref=$3

    hash_ref=()
    local min_len=$((${#keys_ref[@]} < ${#values_ref[@]} ? ${#keys_ref[@]} : ${#values_ref[@]}))

    for ((i=1; i<=min_len; i++)); do
        hash_ref[${keys_ref[$i]}]="${values_ref[$i]}"
    done
}

hash_from_string() {
    local -n hash_ref=$1
    local string="$2"
    local pair_delimiter="${3:-,}"
    local kv_delimiter="${4:-=}"

    hash_ref=()
    local -a pairs=("${(@s:$pair_delimiter:)string}")

    for pair in "${pairs[@]}"; do
        local key="${pair%%$kv_delimiter*}"
        local value="${pair#*$kv_delimiter}"
        hash_ref[$key]="$value"
    done
}

# Hash information
hash_size() {
    local -n hash_ref=$1
    echo "${#hash_ref[@]}"
}

hash_is_empty() {
    local -n hash_ref=$1
    [[ ${#hash_ref[@]} -eq 0 ]]
}

hash_has_key() {
    local -n hash_ref=$1
    local key="$2"
    [[ -n "${hash_ref[$key]+x}" ]]
}

hash_has_value() {
    local -n hash_ref=$1
    local value="$2"

    for val in "${hash_ref[@]}"; do
        [[ "$val" == "$value" ]] && return 0
    done
    return 1
}

# Hash access
hash_get() {
    local -n hash_ref=$1
    local key="$2"
    local default="${3:-}"

    if hash_has_key hash_ref "$key"; then
        echo "${hash_ref[$key]}"
    else
        echo "$default"
    fi
}

hash_set() {
    local -n hash_ref=$1
    local key="$2"
    local value="$3"
    hash_ref[$key]="$value"
}

hash_get_or_set() {
    local -n hash_ref=$1
    local key="$2"
    local default="$3"

    if hash_has_key hash_ref "$key"; then
        echo "${hash_ref[$key]}"
    else
        hash_ref[$key]="$default"
        echo "$default"
    fi
}

hash_keys() {
    local -n hash_ref=$1
    echo "${(k)hash_ref[@]}"
}

hash_values() {
    local -n hash_ref=$1
    echo "${hash_ref[@]}"
}

hash_items() {
    local -n hash_ref=$1

    for key in ${(k)hash_ref}; do
        echo "$key=${hash_ref[$key]}"
    done
}

# Hash modification
hash_delete() {
    local -n hash_ref=$1
    local key="$2"

    if hash_has_key hash_ref "$key"; then
        unset "hash_ref[$key]"
        return 0
    fi
    return 1
}

hash_clear() {
    local -n hash_ref=$1
    hash_ref=()
}

hash_update() {
    local -n hash_ref=$1
    local -n update_ref=$2

    for key in ${(k)update_ref}; do
        hash_ref[$key]="${update_ref[$key]}"
    done
}

hash_merge() {
    local -n hash1_ref=$1
    local -n hash2_ref=$2
    local -n result_ref=$3

    result_ref=()

    # Copy first hash
    for key in ${(k)hash1_ref}; do
        result_ref[$key]="${hash1_ref[$key]}"
    done

    # Merge second hash
    for key in ${(k)hash2_ref}; do
        result_ref[$key]="${hash2_ref[$key]}"
    done
}

hash_setdefault() {
    local -n hash_ref=$1
    local key="$2"
    local default="$3"

    if ! hash_has_key hash_ref "$key"; then
        hash_ref[$key]="$default"
    fi
    echo "${hash_ref[$key]}"
}

# Hash operations
hash_map_keys() {
    local -n hash_ref=$1
    local -n result_ref=$2
    local function="$3"

    result_ref=()
    for key in ${(k)hash_ref}; do
        local new_key="$($function "$key")"
        result_ref[$new_key]="${hash_ref[$key]}"
    done
}

hash_map_values() {
    local -n hash_ref=$1
    local -n result_ref=$2
    local function="$3"

    result_ref=()
    for key in ${(k)hash_ref}; do
        result_ref[$key]="$($function "${hash_ref[$key]}")"
    done
}

hash_filter() {
    local -n hash_ref=$1
    local -n result_ref=$2
    local predicate="$3"

    result_ref=()
    for key in ${(k)hash_ref}; do
        if $predicate "$key" "${hash_ref[$key]}"; then
            result_ref[$key]="${hash_ref[$key]}"
        fi
    done
}

hash_for_each() {
    local -n hash_ref=$1
    local function="$2"

    for key in ${(k)hash_ref}; do
        $function "$key" "${hash_ref[$key]}"
    done
}

hash_find_key() {
    local -n hash_ref=$1
    local value="$2"

    for key in ${(k)hash_ref}; do
        if [[ "${hash_ref[$key]}" == "$value" ]]; then
            echo "$key"
            return 0
        fi
    done
    return 1
}

hash_find_keys() {
    local -n hash_ref=$1
    local value="$2"
    local -a keys=()

    for key in ${(k)hash_ref}; do
        if [[ "${hash_ref[$key]}" == "$value" ]]; then
            keys+=("$key")
        fi
    done

    echo "${keys[@]}"
}

# Hash comparison
hash_equals() {
    local -n hash1_ref=$1
    local -n hash2_ref=$2

    # Check size
    [[ ${#hash1_ref[@]} -ne ${#hash2_ref[@]} ]] && return 1

    # Check all keys and values
    for key in ${(k)hash1_ref}; do
        if ! hash_has_key hash2_ref "$key"; then
            return 1
        fi
        if [[ "${hash1_ref[$key]}" != "${hash2_ref[$key]}" ]]; then
            return 1
        fi
    done

    return 0
}

hash_diff() {
    local -n hash1_ref=$1
    local -n hash2_ref=$2
    local -n result_ref=$3

    result_ref=()
    for key in ${(k)hash1_ref}; do
        if ! hash_has_key hash2_ref "$key" || [[ "${hash1_ref[$key]}" != "${hash2_ref[$key]}" ]]; then
            result_ref[$key]="${hash1_ref[$key]}"
        fi
    done
}

hash_intersect() {
    local -n hash1_ref=$1
    local -n hash2_ref=$2
    local -n result_ref=$3

    result_ref=()
    for key in ${(k)hash1_ref}; do
        if hash_has_key hash2_ref "$key" && [[ "${hash1_ref[$key]}" == "${hash2_ref[$key]}" ]]; then
            result_ref[$key]="${hash1_ref[$key]}"
        fi
    done
}

# Hash conversion
hash_to_array() {
    local -n hash_ref=$1
    local -n keys_ref=$2
    local -n values_ref=$3

    keys_ref=()
    values_ref=()

    for key in ${(k)hash_ref}; do
        keys_ref+=("$key")
        values_ref+=("${hash_ref[$key]}")
    done
}

hash_to_string() {
    local -n hash_ref=$1
    local pair_delimiter="${2:-,}"
    local kv_delimiter="${3:-=}"
    local result=""

    local first=1
    for key in ${(k)hash_ref}; do
        [[ $first -eq 0 ]] && result+="$pair_delimiter"
        result+="${key}${kv_delimiter}${hash_ref[$key]}"
        first=0
    done

    echo "$result"
}

hash_copy() {
    local -n source_ref=$1
    local -n dest_ref=$2

    dest_ref=()
    for key in ${(k)source_ref}; do
        dest_ref[$key]="${source_ref[$key]}"
    done
}

hash_clone() {
    hash_copy "$@"
}

# Hash sorting
hash_sort_by_key() {
    local -n hash_ref=$1
    local -n result_ref=$2
    local order="${3:-asc}"

    result_ref=()
    local -a sorted_keys

    if [[ "$order" == "desc" ]]; then
        sorted_keys=(${(Ok)hash_ref})
    else
        sorted_keys=(${(ok)hash_ref})
    fi

    for key in "${sorted_keys[@]}"; do
        result_ref[$key]="${hash_ref[$key]}"
    done
}

hash_sort_by_value() {
    local -n hash_ref=$1
    local -n result_ref=$2
    local order="${3:-asc}"
    local numeric="${4:-false}"

    result_ref=()

    # Create array of key-value pairs
    local -a pairs=()
    for key in ${(k)hash_ref}; do
        pairs+=("${hash_ref[$key]}:${key}")
    done

    # Sort pairs
    local sort_flags=""
    [[ "$numeric" == "true" ]] && sort_flags="-n"
    [[ "$order" == "desc" ]] && sort_flags="$sort_flags -r"

    local -a sorted_pairs=($(printf '%s\n' "${pairs[@]}" | sort $sort_flags))

    # Rebuild hash
    for pair in "${sorted_pairs[@]}"; do
        local value="${pair%%:*}"
        local key="${pair#*:}"
        result_ref[$key]="${hash_ref[$key]}"
    done
}

# Hash inversion
hash_invert() {
    local -n hash_ref=$1
    local -n result_ref=$2

    result_ref=()
    for key in ${(k)hash_ref}; do
        result_ref[${hash_ref[$key]}]="$key"
    done
}

# Hash grouping
hash_group_by() {
    local -n array_ref=$1
    local -n result_ref=$2
    local key_func="$3"

    result_ref=()
    for item in "${array_ref[@]}"; do
        local key="$($key_func "$item")"
        if hash_has_key result_ref "$key"; then
            result_ref[$key]="${result_ref[$key]} $item"
        else
            result_ref[$key]="$item"
        fi
    done
}

# Hash statistics
hash_count_values() {
    local -n hash_ref=$1
    local -A counts=()

    for value in "${hash_ref[@]}"; do
        ((counts[$value]++))
    done

    for value in ${(k)counts}; do
        echo "$value: ${counts[$value]}"
    done
}

# Hash validation
hash_validate() {
    local -n hash_ref=$1
    local key_validator="$2"
    local value_validator="$3"

    for key in ${(k)hash_ref}; do
        if ! $key_validator "$key"; then
            echo "Invalid key: $key" >&2
            return 1
        fi
        if ! $value_validator "${hash_ref[$key]}"; then
            echo "Invalid value for key $key: ${hash_ref[$key]}" >&2
            return 1
        fi
    done

    return 0
}

# Hash debugging
hash_print() {
    local -n hash_ref=$1
    local format="${2:-%s = %s\n}"

    for key in ${(ok)hash_ref}; do
        printf "$format" "$key" "${hash_ref[$key]}"
    done
}

hash_dump() {
    local -n hash_ref=$1
    local name="${2:-hash}"

    echo "$name (${#hash_ref[@]} items):"
    for key in ${(ok)hash_ref}; do
        echo "  [$key] = ${hash_ref[$key]}"
    done
}

# Hash serialization
hash_to_json() {
    local -n hash_ref=$1
    local compact="${2:-false}"
    local output="{"

    local first=1
    for key in ${(k)hash_ref}; do
        if [[ $first -eq 0 ]]; then
            output+=","
            [[ "$compact" != "true" ]] && output+=" "
        fi

        # Escape key and value
        local escaped_key="${key//\"/\\\"}"
        local escaped_value="${hash_ref[$key]//\"/\\\"}"

        output+="\"${escaped_key}\":"
        [[ "$compact" != "true" ]] && output+=" "

        # Check if value is numeric
        if [[ "${escaped_value}" =~ ^-?[0-9]+\.?[0-9]*$ ]]; then
            output+="${escaped_value}"
        else
            output+="\"${escaped_value}\""
        fi

        first=0
    done

    output+="}"
    echo "$output"
}

# Default values
hash_with_defaults() {
    local -n hash_ref=$1
    local -n defaults_ref=$2
    local -n result_ref=$3

    result_ref=()

    # Copy defaults first
    for key in ${(k)defaults_ref}; do
        result_ref[$key]="${defaults_ref[$key]}"
    done

    # Override with actual values
    for key in ${(k)hash_ref}; do
        result_ref[$key]="${hash_ref[$key]}"
    done
}
