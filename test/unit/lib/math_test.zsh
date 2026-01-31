#!/usr/bin/env zsh
# Unit tests for math.zsh library

# Get the test directory path
TEST_DIR="$(cd "$(dirname "$(dirname "$(dirname "$0")")")" && pwd)"
DOTFILES_DIR="$(dirname "$TEST_DIR")"

# Set up test environment
export TEST_TMP_DIR="${TEST_TMP_DIR:-/tmp/dotfiles_test_$$}"
mkdir -p "$TEST_TMP_DIR"

# Test framework
source "${TEST_DIR}/lib/test_helpers.zsh"

# Source the library under test
source "${DOTFILES_DIR}/src/lib/math.zsh"

# ============================================================================
# Basic Arithmetic Tests
# ============================================================================

test_add_integers() {
  test_case "add sums integers"
  local result=$(add 1 2 3 4 5)
  if [[ "$result" == "15" ]]; then
    pass
  else
    fail "Expected 15, got: $result"
  fi
}

test_add_floats() {
  test_case "add sums floats"
  local result=$(add 1.5 2.5)
  if [[ "$result" == "4" ]]; then
    pass
  else
    fail "Expected 4, got: $result"
  fi
}

test_subtract_positive() {
  test_case "subtract positive result"
  local result=$(subtract 10 3)
  if [[ "$result" == "7" ]]; then
    pass
  else
    fail "Expected 7, got: $result"
  fi
}

test_subtract_negative_result() {
  test_case "subtract negative result"
  local result=$(subtract 3 10)
  if [[ "$result" == "-7" ]]; then
    pass
  else
    fail "Expected -7, got: $result"
  fi
}

test_multiply_integers() {
  test_case "multiply integers"
  local result=$(multiply 3 4 5)
  if [[ "$result" == "60" ]]; then
    pass
  else
    fail "Expected 60, got: $result"
  fi
}

test_divide_exact() {
  test_case "divide exact division"
  local result=$(divide 10 2)
  if [[ "$result" == "5.00" ]]; then
    pass
  else
    fail "Expected 5.00, got: $result"
  fi
}

test_divide_with_precision() {
  test_case "divide with custom precision"
  local result=$(divide 10 3 4)
  if [[ "$result" == "3.3333" ]]; then
    pass
  else
    fail "Expected 3.3333, got: $result"
  fi
}

test_divide_by_zero() {
  test_case "divide by zero returns error"
  if ! divide 10 0 2>/dev/null; then
    pass
  else
    fail "Expected error for division by zero"
  fi
}

test_modulo() {
  test_case "modulo returns remainder"
  local result=$(modulo 17 5)
  if [[ "$result" == "2" ]]; then
    pass
  else
    fail "Expected 2, got: $result"
  fi
}

test_power() {
  test_case "power calculates exponent"
  local result=$(power 2 10)
  if [[ "$result" == "1024" ]]; then
    pass
  else
    fail "Expected 1024, got: $result"
  fi
}

test_sqrt() {
  test_case "sqrt calculates square root"
  local result=$(sqrt 16)
  if [[ "$result" == "4.00" ]]; then
    pass
  else
    fail "Expected 4.00, got: $result"
  fi
}

test_abs_negative() {
  test_case "abs of negative number"
  local result=$(abs -42)
  if [[ "$result" == "42" ]]; then
    pass
  else
    fail "Expected 42, got: $result"
  fi
}

test_abs_positive() {
  test_case "abs of positive number"
  local result=$(abs 42)
  if [[ "$result" == "42" ]]; then
    pass
  else
    fail "Expected 42, got: $result"
  fi
}

test_round() {
  test_case "round to nearest integer"
  local result=$(round 3.7)
  if [[ "$result" == "4" ]]; then
    pass
  else
    fail "Expected 4, got: $result"
  fi
}

test_floor() {
  test_case "floor truncates down"
  local result=$(floor 3.9)
  if [[ "$result" == "3" ]]; then
    pass
  else
    fail "Expected 3, got: $result"
  fi
}

test_ceil() {
  test_case "ceil rounds up"
  local result=$(ceil 3.1)
  if [[ "$result" == "4" ]]; then
    pass
  else
    fail "Expected 4, got: $result"
  fi
}

test_min() {
  test_case "min finds minimum"
  local result=$(min 5 3 8 1 9)
  if [[ "$result" == "1" ]]; then
    pass
  else
    fail "Expected 1, got: $result"
  fi
}

test_max() {
  test_case "max finds maximum"
  local result=$(max 5 3 8 1 9)
  if [[ "$result" == "9" ]]; then
    pass
  else
    fail "Expected 9, got: $result"
  fi
}

# ============================================================================
# Statistical Tests
# ============================================================================

test_average() {
  test_case "average calculates mean"
  local result=$(average 10 20 30)
  if [[ "$result" == "20" ]]; then
    pass
  else
    fail "Expected 20, got: $result"
  fi
}

test_sum() {
  test_case "sum adds all values"
  local result=$(sum 1 2 3 4 5)
  if [[ "$result" == "15" ]]; then
    pass
  else
    fail "Expected 15, got: $result"
  fi
}

test_product() {
  test_case "product multiplies all values"
  local result=$(product 2 3 4)
  if [[ "$result" == "24" ]]; then
    pass
  else
    fail "Expected 24, got: $result"
  fi
}

test_median_odd() {
  test_case "median of odd count"
  local result=$(median 1 3 5 7 9)
  if [[ "$result" == "5" ]]; then
    pass
  else
    fail "Expected 5, got: $result"
  fi
}

test_mode() {
  test_case "mode finds most frequent"
  local result=$(mode 1 2 2 3 3 3 4)
  if [[ "$result" == "3" ]]; then
    pass
  else
    fail "Expected 3, got: $result"
  fi
}

test_range() {
  test_case "range calculates difference"
  local result=$(range 5 10 3 8)
  if [[ "$result" == "7" ]]; then
    pass
  else
    fail "Expected 7, got: $result"
  fi
}

test_percentage() {
  test_case "percentage calculates correctly"
  local result=$(percentage 25 100)
  if [[ "$result" == "25.00" ]]; then
    pass
  else
    fail "Expected 25.00, got: $result"
  fi
}

# ============================================================================
# Conversion Tests
# ============================================================================

test_dec_to_bin() {
  test_case "dec_to_bin converts to binary"
  local result=$(dec_to_bin 10)
  if [[ "$result" == "1010" ]]; then
    pass
  else
    fail "Expected 1010, got: $result"
  fi
}

test_bin_to_dec() {
  test_case "bin_to_dec converts to decimal"
  local result=$(bin_to_dec 1010)
  if [[ "$result" == "10" ]]; then
    pass
  else
    fail "Expected 10, got: $result"
  fi
}

test_dec_to_hex() {
  test_case "dec_to_hex converts to hex"
  local result=$(dec_to_hex 255)
  if [[ "$result" == "FF" ]]; then
    pass
  else
    fail "Expected FF, got: $result"
  fi
}

test_hex_to_dec() {
  test_case "hex_to_dec converts to decimal"
  local result=$(hex_to_dec "FF")
  if [[ "$result" == "255" ]]; then
    pass
  else
    fail "Expected 255, got: $result"
  fi
}

# ============================================================================
# Random Number Tests
# ============================================================================

test_random_int_in_range() {
  test_case "random_int returns value in range"
  local result=$(random_int 1 10)
  if [[ $result -ge 1 ]] && [[ $result -le 10 ]]; then
    pass
  else
    fail "Expected 1-10, got: $result"
  fi
}

test_random_float_range() {
  test_case "random_float returns value 0-1"
  local result=$(random_float 4)
  # Check if it's a valid float format
  if [[ "$result" =~ ^0\.[0-9]+$ ]]; then
    pass
  else
    fail "Expected 0.xxxx format, got: $result"
  fi
}

# ============================================================================
# Number Theory Tests
# ============================================================================

test_gcd() {
  test_case "gcd finds greatest common divisor"
  local result=$(gcd 48 18)
  if [[ "$result" == "6" ]]; then
    pass
  else
    fail "Expected 6, got: $result"
  fi
}

test_lcm() {
  test_case "lcm finds least common multiple"
  local result=$(lcm 4 6)
  if [[ "$result" == "12" ]]; then
    pass
  else
    fail "Expected 12, got: $result"
  fi
}

test_is_prime_true() {
  test_case "is_prime returns true for prime"
  if is_prime 17; then
    pass
  else
    fail "17 should be prime"
  fi
}

test_is_prime_false() {
  test_case "is_prime returns false for non-prime"
  if ! is_prime 15; then
    pass
  else
    fail "15 should not be prime"
  fi
}

test_factorial() {
  test_case "factorial calculates correctly"
  local result=$(factorial 5)
  if [[ "$result" == "120" ]]; then
    pass
  else
    fail "Expected 120, got: $result"
  fi
}

test_fibonacci() {
  test_case "fibonacci returns correct value"
  local result=$(fibonacci 10)
  if [[ "$result" == "55" ]]; then
    pass
  else
    fail "Expected 55, got: $result"
  fi
}

# ============================================================================
# Geometric Tests
# ============================================================================

test_hypotenuse() {
  test_case "hypotenuse calculates correctly"
  local result=$(hypotenuse 3 4)
  if [[ "$result" == "5.00" ]]; then
    pass
  else
    fail "Expected 5.00, got: $result"
  fi
}

test_circle_area() {
  test_case "circle_area calculates correctly"
  local result=$(circle_area 1)
  # Pi should give approximately 3.14
  if [[ "$result" =~ ^3\.14 ]]; then
    pass
  else
    fail "Expected ~3.14, got: $result"
  fi
}

# ============================================================================
# Run Tests
# ============================================================================

test_suite "Math Library" \
  test_add_integers \
  test_add_floats \
  test_subtract_positive \
  test_subtract_negative_result \
  test_multiply_integers \
  test_divide_exact \
  test_divide_with_precision \
  test_divide_by_zero \
  test_modulo \
  test_power \
  test_sqrt \
  test_abs_negative \
  test_abs_positive \
  test_round \
  test_floor \
  test_ceil \
  test_min \
  test_max \
  test_average \
  test_sum \
  test_product \
  test_median_odd \
  test_mode \
  test_range \
  test_percentage \
  test_dec_to_bin \
  test_bin_to_dec \
  test_dec_to_hex \
  test_hex_to_dec \
  test_random_int_in_range \
  test_random_float_range \
  test_gcd \
  test_lcm \
  test_is_prime_true \
  test_is_prime_false \
  test_factorial \
  test_fibonacci \
  test_hypotenuse \
  test_circle_area
