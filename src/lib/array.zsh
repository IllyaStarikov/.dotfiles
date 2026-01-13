#!/usr/bin/env zsh

# array.zsh - Array manipulation and operations library
# Provides comprehensive array handling functions

# Array creation and initialization
array_new() {
    local -n arr_ref=$1
    shift
    arr_ref=("$@")
}

array_from_string() {
    local -n arr_ref=$1
    local string="$2"
    local delimiter="${3:- }"

    arr_ref=("${(@s:$delimiter:)string}")
}

array_range() {
    local -n arr_ref=$1
    local start="$2"
    local end="$3"
    local step="${4:-1}"

    arr_ref=()
    for ((i=start; i<=end; i+=step)); do
        arr_ref+=($i)
    done
}

array_fill() {
    local -n arr_ref=$1
    local size="$2"
    local value="$3"

    arr_ref=()
    for ((i=0; i<size; i++)); do
        arr_ref+=("$value")
    done
}

# Array information
array_length() {
    local -n arr_ref=$1
    echo "${#arr_ref[@]}"
}

array_is_empty() {
    local -n arr_ref=$1
    [[ ${#arr_ref[@]} -eq 0 ]]
}

array_contains() {
    local -n arr_ref=$1
    local needle="$2"

    for item in "${arr_ref[@]}"; do
        [[ "$item" == "$needle" ]] && return 0
    done
    return 1
}

array_index_of() {
    local -n arr_ref=$1
    local needle="$2"

    for i in {1..${#arr_ref[@]}}; do
        if [[ "${arr_ref[$i]}" == "$needle" ]]; then
            echo "$i"
            return 0
        fi
    done
    echo "-1"
    return 1
}

array_last_index_of() {
    local -n arr_ref=$1
    local needle="$2"
    local last_index=-1

    for i in {1..${#arr_ref[@]}}; do
        if [[ "${arr_ref[$i]}" == "$needle" ]]; then
            last_index=$i
        fi
    done

    echo "$last_index"
    [[ $last_index -ne -1 ]]
}

# Array access
array_get() {
    local -n arr_ref=$1
    local index="$2"
    local default="${3:-}"

    if [[ $index -ge 1 ]] && [[ $index -le ${#arr_ref[@]} ]]; then
        echo "${arr_ref[$index]}"
    else
        echo "$default"
    fi
}

array_first() {
    local -n arr_ref=$1
    local count="${2:-1}"

    if [[ $count -eq 1 ]]; then
        echo "${arr_ref[1]}"
    else
        echo "${arr_ref[@]:0:$count}"
    fi
}

array_last() {
    local -n arr_ref=$1
    local count="${2:-1}"

    if [[ $count -eq 1 ]]; then
        echo "${arr_ref[-1]}"
    else
        echo "${arr_ref[@]: -$count}"
    fi
}

array_slice() {
    local -n arr_ref=$1
    local -n result_ref=$2
    local start="${3:-1}"
    local length="${4:-}"

    if [[ -z "$length" ]]; then
        result_ref=("${arr_ref[@]:$((start-1))}")
    else
        result_ref=("${arr_ref[@]:$((start-1)):$length}")
    fi
}

# Array modification
array_push() {
    local -n arr_ref=$1
    shift
    arr_ref+=("$@")
}

array_pop() {
    local -n arr_ref=$1

    if [[ ${#arr_ref[@]} -gt 0 ]]; then
        echo "${arr_ref[-1]}"
        arr_ref=("${arr_ref[@]:0:$((${#arr_ref[@]}-1))}")
        return 0
    fi
    return 1
}

array_shift() {
    local -n arr_ref=$1

    if [[ ${#arr_ref[@]} -gt 0 ]]; then
        echo "${arr_ref[1]}"
        arr_ref=("${arr_ref[@]:1}")
        return 0
    fi
    return 1
}

array_unshift() {
    local -n arr_ref=$1
    shift
    arr_ref=("$@" "${arr_ref[@]}")
}

array_insert() {
    local -n arr_ref=$1
    local index="$2"
    local value="$3"

    if [[ $index -le 1 ]]; then
        arr_ref=("$value" "${arr_ref[@]}")
    elif [[ $index -gt ${#arr_ref[@]} ]]; then
        arr_ref+=("$value")
    else
        arr_ref=("${arr_ref[@]:0:$((index-1))}" "$value" "${arr_ref[@]:$((index-1))}")
    fi
}

array_remove_at() {
    local -n arr_ref=$1
    local index="$2"

    if [[ $index -ge 1 ]] && [[ $index -le ${#arr_ref[@]} ]]; then
        arr_ref=("${arr_ref[@]:0:$((index-1))}" "${arr_ref[@]:$index}")
        return 0
    fi
    return 1
}

array_remove() {
    local -n arr_ref=$1
    local value="$2"
    local all="${3:-false}"

    local -a new_array=()
    local removed=0

    for item in "${arr_ref[@]}"; do
        if [[ "$item" == "$value" ]] && ([[ "$all" == "true" ]] || [[ $removed -eq 0 ]]); then
            ((removed++))
        else
            new_array+=("$item")
        fi
    done

    arr_ref=("${new_array[@]}")
    [[ $removed -gt 0 ]]
}

array_clear() {
    local -n arr_ref=$1
    arr_ref=()
}

array_set() {
    local -n arr_ref=$1
    local index="$2"
    local value="$3"

    if [[ $index -ge 1 ]] && [[ $index -le ${#arr_ref[@]} ]]; then
        arr_ref[$index]="$value"
        return 0
    fi
    return 1
}

# Array transformation
array_reverse() {
    local -n arr_ref=$1
    local -a reversed=()

    for ((i=${#arr_ref[@]}; i>=1; i--)); do
        reversed+=("${arr_ref[$i]}")
    done

    arr_ref=("${reversed[@]}")
}

array_sort() {
    local -n arr_ref=$1
    local order="${2:-asc}"  # asc or desc
    local numeric="${3:-false}"

    local sort_flags=""
    [[ "$numeric" == "true" ]] && sort_flags="-n"
    [[ "$order" == "desc" ]] && sort_flags="$sort_flags -r"

    arr_ref=($(printf '%s\n' "${arr_ref[@]}" | sort "$sort_flags"))
}

array_unique() {
    local -n arr_ref=$1
    local -a unique=()
    local -A seen=()

    for item in "${arr_ref[@]}"; do
        if [[ -z "${seen[$item]}" ]]; then
            unique+=("$item")
            seen[$item]=1
        fi
    done

    arr_ref=("${unique[@]}")
}

array_shuffle() {
    local -n arr_ref=$1
    local -a shuffled=("${arr_ref[@]}")
    local n=${#shuffled[@]}

    for ((i=n-1; i>0; i--)); do
        local j=$((RANDOM % (i+1)))
        local temp="${shuffled[$i]}"
        shuffled[$i]="${shuffled[$j]}"
        shuffled[$j]="$temp"
    done

    arr_ref=("${shuffled[@]}")
}

array_rotate() {
    local -n arr_ref=$1
    local positions="${2:-1}"
    local direction="${3:-right}"  # left or right

    local n=${#arr_ref[@]}
    [[ $n -eq 0 ]] && return

    positions=$((positions % n))
    [[ $positions -eq 0 ]] && return

    if [[ "$direction" == "right" ]]; then
        arr_ref=("${arr_ref[@]: -$positions}" "${arr_ref[@]:0:$((n-positions))}")
    else
        arr_ref=("${arr_ref[@]:$positions}" "${arr_ref[@]:0:$positions}")
    fi
}

# Array operations
array_map() {
    local -n arr_ref=$1
    local -n result_ref=$2
    local function="$3"

    result_ref=()
    for item in "${arr_ref[@]}"; do
        result_ref+=("$($function "$item")")
    done
}

array_filter() {
    local -n arr_ref=$1
    local -n result_ref=$2
    local predicate="$3"

    result_ref=()
    for item in "${arr_ref[@]}"; do
        if $predicate "$item"; then
            result_ref+=("$item")
        fi
    done
}

array_reduce() {
    local -n arr_ref=$1
    local function="$2"
    local initial="${3:-}"

    local accumulator="$initial"
    for item in "${arr_ref[@]}"; do
        if [[ -z "$accumulator" ]]; then
            accumulator="$item"
        else
            accumulator="$($function "$accumulator" "$item")"
        fi
    done

    echo "$accumulator"
}

array_for_each() {
    local -n arr_ref=$1
    local function="$2"

    for item in "${arr_ref[@]}"; do
        $function "$item"
    done
}

array_find() {
    local -n arr_ref=$1
    local predicate="$2"

    for item in "${arr_ref[@]}"; do
        if $predicate "$item"; then
            echo "$item"
            return 0
        fi
    done
    return 1
}

array_find_index() {
    local -n arr_ref=$1
    local predicate="$2"

    for i in {1..${#arr_ref[@]}}; do
        if $predicate "${arr_ref[$i]}"; then
            echo "$i"
            return 0
        fi
    done
    echo "-1"
    return 1
}

array_every() {
    local -n arr_ref=$1
    local predicate="$2"

    for item in "${arr_ref[@]}"; do
        if ! $predicate "$item"; then
            return 1
        fi
    done
    return 0
}

array_some() {
    local -n arr_ref=$1
    local predicate="$2"

    for item in "${arr_ref[@]}"; do
        if $predicate "$item"; then
            return 0
        fi
    done
    return 1
}

# Array comparison
array_equals() {
    local -n arr1_ref=$1
    local -n arr2_ref=$2

    [[ ${#arr1_ref[@]} -ne ${#arr2_ref[@]} ]] && return 1

    for i in {1..${#arr1_ref[@]}}; do
        [[ "${arr1_ref[$i]}" != "${arr2_ref[$i]}" ]] && return 1
    done
    return 0
}

array_diff() {
    local -n arr1_ref=$1
    local -n arr2_ref=$2
    local -n result_ref=$3

    result_ref=()
    for item in "${arr1_ref[@]}"; do
        local found=0
        for item2 in "${arr2_ref[@]}"; do
            if [[ "$item" == "$item2" ]]; then
                found=1
                break
            fi
        done
        [[ $found -eq 0 ]] && result_ref+=("$item")
    done
}

array_intersect() {
    local -n arr1_ref=$1
    local -n arr2_ref=$2
    local -n result_ref=$3

    result_ref=()
    for item in "${arr1_ref[@]}"; do
        for item2 in "${arr2_ref[@]}"; do
            if [[ "$item" == "$item2" ]]; then
                result_ref+=("$item")
                break
            fi
        done
    done
}

array_union() {
    local -n arr1_ref=$1
    local -n arr2_ref=$2
    local -n result_ref=$3

    result_ref=("${arr1_ref[@]}" "${arr2_ref[@]}")
    array_unique result_ref
}

# Array conversion
array_join() {
    local -n arr_ref=$1
    local delimiter="${2:-,}"
    local result=""

    for ((i=1; i<=${#arr_ref[@]}; i++)); do
        result+="${arr_ref[$i]}"
        [[ $i -lt ${#arr_ref[@]} ]] && result+="$delimiter"
    done

    echo "$result"
}

array_to_string() {
    array_join "$@"
}

array_copy() {
    local -n source_ref=$1
    local -n dest_ref=$2
    dest_ref=("${source_ref[@]}")
}

array_clone() {
    array_copy "$@"
}

# Array grouping
array_chunk() {
    local -n arr_ref=$1
    local chunk_size="$2"
    local -n result_ref=$3

    result_ref=()
    local -a chunk=()

    for item in "${arr_ref[@]}"; do
        chunk+=("$item")
        if [[ ${#chunk[@]} -eq $chunk_size ]]; then
            result_ref+=("$(array_join chunk ' ')")
            chunk=()
        fi
    done

    [[ ${#chunk[@]} -gt 0 ]] && result_ref+=("$(array_join chunk ' ')")
}

array_partition() {
    local -n arr_ref=$1
    local predicate="$2"
    local -n true_ref=$3
    local -n false_ref=$4

    true_ref=()
    false_ref=()

    for item in "${arr_ref[@]}"; do
        if $predicate "$item"; then
            true_ref+=("$item")
        else
            false_ref+=("$item")
        fi
    done
}

# Array statistics
array_count() {
    local -n arr_ref=$1
    local value="$2"
    local count=0

    for item in "${arr_ref[@]}"; do
        [[ "$item" == "$value" ]] && ((count++))
    done

    echo "$count"
}

array_frequency() {
    local -n arr_ref=$1
    local -A freq=()

    for item in "${arr_ref[@]}"; do
        ((freq[$item]++))
    done

    for key in ${(k)freq}; do
        echo "$key: ${freq[$key]}"
    done
}

array_min() {
    local -n arr_ref=$1
    local numeric="${2:-false}"

    [[ ${#arr_ref[@]} -eq 0 ]] && return 1

    local min="${arr_ref[1]}"
    for item in "${arr_ref[@]:1}"; do
        if [[ "$numeric" == "true" ]]; then
            [[ $item -lt $min ]] && min="$item"
        else
            [[ "$item" < "$min" ]] && min="$item"
        fi
    done

    echo "$min"
}

array_max() {
    local -n arr_ref=$1
    local numeric="${2:-false}"

    [[ ${#arr_ref[@]} -eq 0 ]] && return 1

    local max="${arr_ref[1]}"
    for item in "${arr_ref[@]:1}"; do
        if [[ "$numeric" == "true" ]]; then
            [[ $item -gt $max ]] && max="$item"
        else
            [[ "$item" > "$max" ]] && max="$item"
        fi
    done

    echo "$max"
}

array_sum() {
    local -n arr_ref=$1
    local sum=0

    for item in "${arr_ref[@]}"; do
        sum=$((sum + item))
    done

    echo "$sum"
}

array_average() {
    local -n arr_ref=$1

    [[ ${#arr_ref[@]} -eq 0 ]] && return 1

    local sum=$(array_sum arr_ref)
    echo $((sum / ${#arr_ref[@]}))
}

# Array debugging
array_print() {
    local -n arr_ref=$1
    local format="${2:-%s\n}"

    for item in "${arr_ref[@]}"; do
        printf "$format" "$item"
    done
}

array_dump() {
    local -n arr_ref=$1
    local name="${2:-array}"

    echo "$name (${#arr_ref[@]} elements):"
    for i in {1..${#arr_ref[@]}}; do
        echo "  [$i] = ${arr_ref[$i]}"
    done
}
