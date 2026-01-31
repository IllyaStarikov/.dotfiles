#!/usr/bin/env zsh
# Unit tests for array.zsh library

# Get the test directory path
TEST_DIR="$(cd "$(dirname "$(dirname "$(dirname "$0")")")" && pwd)"
DOTFILES_DIR="$(dirname "$TEST_DIR")"

# Set up test environment
export TEST_TMP_DIR="${TEST_TMP_DIR:-/tmp/dotfiles_test_$$}"
mkdir -p "$TEST_TMP_DIR"

# Test framework
source "${TEST_DIR}/lib/test_helpers.zsh"

# Source the library under test
source "${DOTFILES_DIR}/src/lib/array.zsh"

# ============================================================================
# Array Creation Tests
# ============================================================================

test_array_new_empty() {
  test_case "array_new creates empty array"
  local -a arr
  array_new arr
  if [[ ${#arr[@]} -eq 0 ]]; then
    pass
  else
    fail "Expected empty array, got ${#arr[@]} elements"
  fi
}

test_array_new_with_elements() {
  test_case "array_new with elements"
  local -a arr
  array_new arr "a" "b" "c"
  if [[ ${#arr[@]} -eq 3 ]] && [[ "${arr[1]}" == "a" ]] && [[ "${arr[3]}" == "c" ]]; then
    pass
  else
    fail "Expected 3 elements (a,b,c), got: ${arr[*]}"
  fi
}

test_array_from_string_default_delimiter() {
  test_case "array_from_string with default space delimiter"
  local -a arr
  array_from_string arr "one two three"
  if [[ ${#arr[@]} -eq 3 ]] && [[ "${arr[1]}" == "one" ]] && [[ "${arr[3]}" == "three" ]]; then
    pass
  else
    fail "Expected [one,two,three], got: ${arr[*]}"
  fi
}

test_array_from_string_custom_delimiter() {
  test_case "array_from_string with custom delimiter"
  local -a arr
  array_from_string arr "a,b,c" ","
  if [[ ${#arr[@]} -eq 3 ]] && [[ "${arr[2]}" == "b" ]]; then
    pass
  else
    fail "Expected [a,b,c], got: ${arr[*]}"
  fi
}

test_array_range_ascending() {
  test_case "array_range ascending"
  local -a arr
  array_range arr 1 5
  if [[ ${#arr[@]} -eq 5 ]] && [[ "${arr[1]}" == "1" ]] && [[ "${arr[5]}" == "5" ]]; then
    pass
  else
    fail "Expected [1,2,3,4,5], got: ${arr[*]}"
  fi
}

test_array_range_with_step() {
  test_case "array_range with step"
  local -a arr
  array_range arr 0 10 2
  if [[ ${#arr[@]} -eq 6 ]] && [[ "${arr[3]}" == "4" ]]; then
    pass
  else
    fail "Expected [0,2,4,6,8,10], got: ${arr[*]}"
  fi
}

test_array_fill() {
  test_case "array_fill creates filled array"
  local -a arr
  array_fill arr 3 "x"
  if [[ ${#arr[@]} -eq 3 ]] && [[ "${arr[1]}" == "x" ]] && [[ "${arr[3]}" == "x" ]]; then
    pass
  else
    fail "Expected [x,x,x], got: ${arr[*]}"
  fi
}

# ============================================================================
# Array Information Tests
# ============================================================================

test_array_length_empty() {
  test_case "array_length returns 0 for empty array"
  local -a arr=()
  local len=$(array_length arr)
  if [[ "$len" == "0" ]]; then
    pass
  else
    fail "Expected 0, got: $len"
  fi
}

test_array_length_with_elements() {
  test_case "array_length returns correct count"
  local -a arr=(a b c d e)
  local len=$(array_length arr)
  if [[ "$len" == "5" ]]; then
    pass
  else
    fail "Expected 5, got: $len"
  fi
}

test_array_is_empty_true() {
  test_case "array_is_empty returns true for empty array"
  local -a arr=()
  if array_is_empty arr; then
    pass
  else
    fail "Expected true for empty array"
  fi
}

test_array_is_empty_false() {
  test_case "array_is_empty returns false for non-empty array"
  local -a arr=(a)
  if ! array_is_empty arr; then
    pass
  else
    fail "Expected false for non-empty array"
  fi
}

test_array_contains_found() {
  test_case "array_contains finds existing element"
  local -a arr=(apple banana cherry)
  if array_contains arr "banana"; then
    pass
  else
    fail "Expected to find 'banana'"
  fi
}

test_array_contains_not_found() {
  test_case "array_contains returns false for missing element"
  local -a arr=(apple banana cherry)
  if ! array_contains arr "grape"; then
    pass
  else
    fail "Should not find 'grape'"
  fi
}

test_array_index_of_found() {
  test_case "array_index_of returns correct index"
  local -a arr=(apple banana cherry)
  local idx=$(array_index_of arr "banana")
  if [[ "$idx" == "2" ]]; then
    pass
  else
    fail "Expected index 2, got: $idx"
  fi
}

test_array_index_of_not_found() {
  test_case "array_index_of returns -1 for missing element"
  local -a arr=(apple banana cherry)
  local idx=$(array_index_of arr "grape")
  if [[ "$idx" == "-1" ]]; then
    pass
  else
    fail "Expected -1, got: $idx"
  fi
}

test_array_last_index_of() {
  test_case "array_last_index_of returns last occurrence"
  local -a arr=(a b a c a)
  local idx=$(array_last_index_of arr "a")
  if [[ "$idx" == "5" ]]; then
    pass
  else
    fail "Expected 5, got: $idx"
  fi
}

# ============================================================================
# Array Access Tests
# ============================================================================

test_array_get_valid_index() {
  test_case "array_get returns element at valid index"
  local -a arr=(one two three)
  local val=$(array_get arr 2)
  if [[ "$val" == "two" ]]; then
    pass
  else
    fail "Expected 'two', got: $val"
  fi
}

test_array_get_invalid_index_default() {
  test_case "array_get returns default for invalid index"
  local -a arr=(one two three)
  local val=$(array_get arr 10 "default")
  if [[ "$val" == "default" ]]; then
    pass
  else
    fail "Expected 'default', got: $val"
  fi
}

test_array_first() {
  test_case "array_first returns first element"
  local -a arr=(first second third)
  local val=$(array_first arr)
  if [[ "$val" == "first" ]]; then
    pass
  else
    fail "Expected 'first', got: $val"
  fi
}

test_array_last() {
  test_case "array_last returns last element"
  local -a arr=(first second third)
  local val=$(array_last arr)
  if [[ "$val" == "third" ]]; then
    pass
  else
    fail "Expected 'third', got: $val"
  fi
}

test_array_slice() {
  test_case "array_slice extracts subarray"
  local -a arr=(a b c d e)
  local -a result
  array_slice arr result 2 3
  if [[ ${#result[@]} -eq 3 ]] && [[ "${result[1]}" == "b" ]] && [[ "${result[3]}" == "d" ]]; then
    pass
  else
    fail "Expected [b,c,d], got: ${result[*]}"
  fi
}

# ============================================================================
# Array Modification Tests
# ============================================================================

test_array_push_single() {
  test_case "array_push adds single element"
  local -a arr=(a b)
  array_push arr "c"
  if [[ ${#arr[@]} -eq 3 ]] && [[ "${arr[3]}" == "c" ]]; then
    pass
  else
    fail "Expected [a,b,c], got: ${arr[*]}"
  fi
}

test_array_push_multiple() {
  test_case "array_push adds multiple elements"
  local -a arr=(a)
  array_push arr "b" "c" "d"
  if [[ ${#arr[@]} -eq 4 ]] && [[ "${arr[4]}" == "d" ]]; then
    pass
  else
    fail "Expected [a,b,c,d], got: ${arr[*]}"
  fi
}

test_array_pop_returns_last() {
  test_case "array_pop returns and removes last element"
  local -a arr=(a b c)
  local val=$(array_pop arr)
  if [[ "$val" == "c" ]] && [[ ${#arr[@]} -eq 2 ]]; then
    pass
  else
    fail "Expected 'c' and 2 remaining, got: $val, ${#arr[@]} elements"
  fi
}

test_array_pop_empty() {
  test_case "array_pop fails on empty array"
  local -a arr=()
  if ! array_pop arr >/dev/null 2>&1; then
    pass
  else
    fail "Expected failure on empty array"
  fi
}

test_array_shift() {
  test_case "array_shift returns and removes first element"
  local -a arr=(a b c)
  local val=$(array_shift arr)
  if [[ "$val" == "a" ]] && [[ ${#arr[@]} -eq 2 ]] && [[ "${arr[1]}" == "b" ]]; then
    pass
  else
    fail "Expected 'a' and [b,c] remaining, got: $val, ${arr[*]}"
  fi
}

test_array_unshift() {
  test_case "array_unshift prepends elements"
  local -a arr=(c d)
  array_unshift arr "a" "b"
  if [[ ${#arr[@]} -eq 4 ]] && [[ "${arr[1]}" == "a" ]] && [[ "${arr[2]}" == "b" ]]; then
    pass
  else
    fail "Expected [a,b,c,d], got: ${arr[*]}"
  fi
}

test_array_insert() {
  test_case "array_insert inserts at position"
  local -a arr=(a c d)
  array_insert arr 2 "b"
  if [[ ${#arr[@]} -eq 4 ]] && [[ "${arr[2]}" == "b" ]]; then
    pass
  else
    fail "Expected [a,b,c,d], got: ${arr[*]}"
  fi
}

test_array_remove_at() {
  test_case "array_remove_at removes element at index"
  local -a arr=(a b c d)
  array_remove_at arr 2
  if [[ ${#arr[@]} -eq 3 ]] && [[ "${arr[2]}" == "c" ]]; then
    pass
  else
    fail "Expected [a,c,d], got: ${arr[*]}"
  fi
}

test_array_remove_first() {
  test_case "array_remove removes first occurrence"
  local -a arr=(a b c b d)
  array_remove arr "b"
  if [[ ${#arr[@]} -eq 4 ]] && [[ "${arr[2]}" == "c" ]] && [[ "${arr[3]}" == "b" ]]; then
    pass
  else
    fail "Expected [a,c,b,d], got: ${arr[*]}"
  fi
}

test_array_remove_all() {
  test_case "array_remove with all=true removes all occurrences"
  local -a arr=(a b c b d)
  array_remove arr "b" "true"
  if [[ ${#arr[@]} -eq 3 ]] && ! array_contains arr "b"; then
    pass
  else
    fail "Expected [a,c,d], got: ${arr[*]}"
  fi
}

test_array_clear() {
  test_case "array_clear empties array"
  local -a arr=(a b c)
  array_clear arr
  if [[ ${#arr[@]} -eq 0 ]]; then
    pass
  else
    fail "Expected empty array, got: ${#arr[@]} elements"
  fi
}

test_array_set() {
  test_case "array_set modifies element at index"
  local -a arr=(a b c)
  array_set arr 2 "B"
  if [[ "${arr[2]}" == "B" ]]; then
    pass
  else
    fail "Expected 'B' at index 2, got: ${arr[2]}"
  fi
}

# ============================================================================
# Array Transformation Tests
# ============================================================================

test_array_reverse() {
  test_case "array_reverse reverses array"
  local -a arr=(1 2 3 4 5)
  array_reverse arr
  if [[ "${arr[1]}" == "5" ]] && [[ "${arr[5]}" == "1" ]]; then
    pass
  else
    fail "Expected [5,4,3,2,1], got: ${arr[*]}"
  fi
}

test_array_sort_ascending() {
  test_case "array_sort ascending order"
  local -a arr=(c a b)
  array_sort arr "asc"
  if [[ "${arr[1]}" == "a" ]] && [[ "${arr[3]}" == "c" ]]; then
    pass
  else
    fail "Expected [a,b,c], got: ${arr[*]}"
  fi
}

test_array_sort_descending() {
  test_case "array_sort descending order"
  local -a arr=(a c b)
  array_sort arr "desc"
  if [[ "${arr[1]}" == "c" ]] && [[ "${arr[3]}" == "a" ]]; then
    pass
  else
    fail "Expected [c,b,a], got: ${arr[*]}"
  fi
}

test_array_sort_numeric() {
  test_case "array_sort numeric"
  local -a arr=(10 2 1 20)
  array_sort arr "asc" "true"
  if [[ "${arr[1]}" == "1" ]] && [[ "${arr[4]}" == "20" ]]; then
    pass
  else
    fail "Expected [1,2,10,20], got: ${arr[*]}"
  fi
}

test_array_unique() {
  test_case "array_unique removes duplicates"
  local -a arr=(a b a c b d)
  array_unique arr
  if [[ ${#arr[@]} -eq 4 ]]; then
    pass
  else
    fail "Expected 4 unique elements, got: ${#arr[@]}"
  fi
}

test_array_rotate_right() {
  test_case "array_rotate right"
  local -a arr=(1 2 3 4 5)
  array_rotate arr 2 "right"
  if [[ "${arr[1]}" == "4" ]] && [[ "${arr[2]}" == "5" ]]; then
    pass
  else
    fail "Expected [4,5,1,2,3], got: ${arr[*]}"
  fi
}

test_array_rotate_left() {
  test_case "array_rotate left"
  local -a arr=(1 2 3 4 5)
  array_rotate arr 2 "left"
  if [[ "${arr[1]}" == "3" ]] && [[ "${arr[5]}" == "2" ]]; then
    pass
  else
    fail "Expected [3,4,5,1,2], got: ${arr[*]}"
  fi
}

# ============================================================================
# Array Operations Tests
# ============================================================================

_double() { echo $(($1 * 2)); }

test_array_map() {
  test_case "array_map applies function to each element"
  local -a arr=(1 2 3)
  local -a result
  array_map arr result _double
  if [[ "${result[1]}" == "2" ]] && [[ "${result[2]}" == "4" ]] && [[ "${result[3]}" == "6" ]]; then
    pass
  else
    fail "Expected [2,4,6], got: ${result[*]}"
  fi
}

_is_even() { [[ $(($1 % 2)) -eq 0 ]]; }

test_array_filter() {
  test_case "array_filter keeps matching elements"
  local -a arr=(1 2 3 4 5 6)
  local -a result
  array_filter arr result _is_even
  if [[ ${#result[@]} -eq 3 ]] && [[ "${result[1]}" == "2" ]]; then
    pass
  else
    fail "Expected [2,4,6], got: ${result[*]}"
  fi
}

_sum() { echo $(($1 + $2)); }

test_array_reduce() {
  test_case "array_reduce accumulates values"
  local -a arr=(1 2 3 4)
  local result=$(array_reduce arr _sum 0)
  if [[ "$result" == "10" ]]; then
    pass
  else
    fail "Expected 10, got: $result"
  fi
}

_greater_than_3() { [[ $1 -gt 3 ]]; }

test_array_find() {
  test_case "array_find returns first matching element"
  local -a arr=(1 2 3 4 5)
  local result=$(array_find arr _greater_than_3)
  if [[ "$result" == "4" ]]; then
    pass
  else
    fail "Expected 4, got: $result"
  fi
}

test_array_find_index() {
  test_case "array_find_index returns index of first match"
  local -a arr=(1 2 3 4 5)
  local result=$(array_find_index arr _greater_than_3)
  if [[ "$result" == "4" ]]; then
    pass
  else
    fail "Expected 4, got: $result"
  fi
}

_is_positive() { [[ $1 -gt 0 ]]; }

test_array_every_true() {
  test_case "array_every returns true when all match"
  local -a arr=(1 2 3 4 5)
  if array_every arr _is_positive; then
    pass
  else
    fail "Expected true for all positive numbers"
  fi
}

test_array_every_false() {
  test_case "array_every returns false when one doesn't match"
  local -a arr=(1 2 -3 4 5)
  if ! array_every arr _is_positive; then
    pass
  else
    fail "Expected false with negative number"
  fi
}

test_array_some_true() {
  test_case "array_some returns true when any matches"
  local -a arr=(-1 -2 3 -4)
  if array_some arr _is_positive; then
    pass
  else
    fail "Expected true with one positive number"
  fi
}

test_array_some_false() {
  test_case "array_some returns false when none match"
  local -a arr=(-1 -2 -3)
  if ! array_some arr _is_positive; then
    pass
  else
    fail "Expected false with all negative numbers"
  fi
}

# ============================================================================
# Array Comparison Tests
# ============================================================================

test_array_equals_true() {
  test_case "array_equals returns true for identical arrays"
  local -a arr1=(a b c)
  local -a arr2=(a b c)
  if array_equals arr1 arr2; then
    pass
  else
    fail "Expected arrays to be equal"
  fi
}

test_array_equals_false_content() {
  test_case "array_equals returns false for different content"
  local -a arr1=(a b c)
  local -a arr2=(a b d)
  if ! array_equals arr1 arr2; then
    pass
  else
    fail "Expected arrays to be different"
  fi
}

test_array_equals_false_length() {
  test_case "array_equals returns false for different length"
  local -a arr1=(a b c)
  local -a arr2=(a b)
  if ! array_equals arr1 arr2; then
    pass
  else
    fail "Expected arrays to be different"
  fi
}

test_array_diff() {
  test_case "array_diff finds elements in first not in second"
  local -a arr1=(a b c d)
  local -a arr2=(b d e)
  local -a result
  array_diff arr1 arr2 result
  if [[ ${#result[@]} -eq 2 ]] && array_contains result "a" && array_contains result "c"; then
    pass
  else
    fail "Expected [a,c], got: ${result[*]}"
  fi
}

test_array_intersect() {
  test_case "array_intersect finds common elements"
  local -a arr1=(a b c d)
  local -a arr2=(b d e f)
  local -a result
  array_intersect arr1 arr2 result
  if [[ ${#result[@]} -eq 2 ]] && array_contains result "b" && array_contains result "d"; then
    pass
  else
    fail "Expected [b,d], got: ${result[*]}"
  fi
}

test_array_union() {
  test_case "array_union combines unique elements"
  local -a arr1=(a b c)
  local -a arr2=(b c d)
  local -a result
  array_union arr1 arr2 result
  if [[ ${#result[@]} -eq 4 ]]; then
    pass
  else
    fail "Expected 4 unique elements, got: ${#result[@]}"
  fi
}

# ============================================================================
# Array Conversion Tests
# ============================================================================

test_array_join_default() {
  test_case "array_join with default comma delimiter"
  local -a arr=(a b c)
  local result=$(array_join arr)
  if [[ "$result" == "a,b,c" ]]; then
    pass
  else
    fail "Expected 'a,b,c', got: $result"
  fi
}

test_array_join_custom_delimiter() {
  test_case "array_join with custom delimiter"
  local -a arr=(a b c)
  local result=$(array_join arr " | ")
  if [[ "$result" == "a | b | c" ]]; then
    pass
  else
    fail "Expected 'a | b | c', got: $result"
  fi
}

test_array_copy() {
  test_case "array_copy creates independent copy"
  local -a arr1=(a b c)
  local -a arr2
  array_copy arr1 arr2
  arr1[1]="x"
  if [[ "${arr2[1]}" == "a" ]]; then
    pass
  else
    fail "Expected 'a' in copy, got: ${arr2[1]}"
  fi
}

# ============================================================================
# Array Statistics Tests
# ============================================================================

test_array_count() {
  test_case "array_count counts occurrences"
  local -a arr=(a b a c a)
  local count=$(array_count arr "a")
  if [[ "$count" == "3" ]]; then
    pass
  else
    fail "Expected 3, got: $count"
  fi
}

test_array_min_numeric() {
  test_case "array_min finds minimum numeric value"
  local -a arr=(5 2 8 1 9)
  local min=$(array_min arr "true")
  if [[ "$min" == "1" ]]; then
    pass
  else
    fail "Expected 1, got: $min"
  fi
}

test_array_max_numeric() {
  test_case "array_max finds maximum numeric value"
  local -a arr=(5 2 8 1 9)
  local max=$(array_max arr "true")
  if [[ "$max" == "9" ]]; then
    pass
  else
    fail "Expected 9, got: $max"
  fi
}

test_array_sum() {
  test_case "array_sum calculates sum"
  local -a arr=(1 2 3 4 5)
  local sum=$(array_sum arr)
  if [[ "$sum" == "15" ]]; then
    pass
  else
    fail "Expected 15, got: $sum"
  fi
}

test_array_average() {
  test_case "array_average calculates average"
  local -a arr=(10 20 30)
  local avg=$(array_average arr)
  if [[ "$avg" == "20" ]]; then
    pass
  else
    fail "Expected 20, got: $avg"
  fi
}

# ============================================================================
# Run Tests
# ============================================================================

test_suite "Array Library" \
  test_array_new_empty \
  test_array_new_with_elements \
  test_array_from_string_default_delimiter \
  test_array_from_string_custom_delimiter \
  test_array_range_ascending \
  test_array_range_with_step \
  test_array_fill \
  test_array_length_empty \
  test_array_length_with_elements \
  test_array_is_empty_true \
  test_array_is_empty_false \
  test_array_contains_found \
  test_array_contains_not_found \
  test_array_index_of_found \
  test_array_index_of_not_found \
  test_array_last_index_of \
  test_array_get_valid_index \
  test_array_get_invalid_index_default \
  test_array_first \
  test_array_last \
  test_array_slice \
  test_array_push_single \
  test_array_push_multiple \
  test_array_pop_returns_last \
  test_array_pop_empty \
  test_array_shift \
  test_array_unshift \
  test_array_insert \
  test_array_remove_at \
  test_array_remove_first \
  test_array_remove_all \
  test_array_clear \
  test_array_set \
  test_array_reverse \
  test_array_sort_ascending \
  test_array_sort_descending \
  test_array_sort_numeric \
  test_array_unique \
  test_array_rotate_right \
  test_array_rotate_left \
  test_array_map \
  test_array_filter \
  test_array_reduce \
  test_array_find \
  test_array_find_index \
  test_array_every_true \
  test_array_every_false \
  test_array_some_true \
  test_array_some_false \
  test_array_equals_true \
  test_array_equals_false_content \
  test_array_equals_false_length \
  test_array_diff \
  test_array_intersect \
  test_array_union \
  test_array_join_default \
  test_array_join_custom_delimiter \
  test_array_copy \
  test_array_count \
  test_array_min_numeric \
  test_array_max_numeric \
  test_array_sum \
  test_array_average
