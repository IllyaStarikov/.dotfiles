#!/bin/zsh
# Script to convert describe/it tests to simple framework

# Function to convert a single test file
convert_test_file() {
    local input_file="$1"
    local output_file="${input_file%.sh}_zsh.sh"
    
    echo "Converting: $input_file -> $output_file"
    
    # Read the original file
    local content=$(<"$input_file")
    
    # Extract test subject from filename
    local test_subject=$(basename "$input_file" _test.sh)
    
    # Start building the new test file
    cat > "$output_file" << 'EOF'
#!/bin/zsh
# Converted test for simple framework

source "$(dirname "$0")/../../lib/simple_framework.sh"

# Set up environment
export DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$(dirname "$0")/../../.." && pwd)}"

EOF
    
    # Add test header
    echo "echo \"=== Testing ${test_subject} ===\"" >> "$output_file"
    echo "" >> "$output_file"
    
    # Extract and convert tests
    # This is a simplified conversion - each file needs manual review
    echo "# TODO: Convert tests from describe/it syntax" >> "$output_file"
    echo "# Original tests:" >> "$output_file"
    echo "$content" | grep -E '^\s*(it|describe) ' | sed 's/^/# /' >> "$output_file"
    echo "" >> "$output_file"
    echo "print_test_summary" >> "$output_file"
    
    chmod +x "$output_file"
}

# Find all incompatible test files
find tests/unit -name "*_test.sh" ! -name "*_zsh.sh" | while read -r file; do
    convert_test_file "$file"
done

echo "Conversion templates created. Manual editing required for each test."