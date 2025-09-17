# ZSH Library System

A comprehensive collection of ZSH library modules providing extensive functionality for shell scripting.

## Overview

This directory contains a modular ZSH library system with 16+ specialized modules covering everything from basic utilities to advanced features like JSON/YAML parsing, SSH operations, and unit testing.

## Quick Start

```zsh
# Source the master loader
source $DOTFILES_DIR/src/lib/lib.zsh

# Load specific libraries
lib_load colors
lib_load logging

# Or load core libraries (colors, utils, logging, die)
lib_load_core

# Or load everything
lib_load_everything
```

## Available Libraries

### Core Libraries

#### colors.zsh

Terminal colors and styling with support for 16-color, 256-color, and true color.

```zsh
lib_load colors
echo "${COLORS[RED]}Error!${COLORS[RESET]}"
print_color "Success!" "GREEN" "BOLD"
```

#### utils.zsh

General utility functions for string manipulation, file operations, and system checks.

```zsh
lib_load utils
trim "  hello  "
file_exists "/path/to/file"
is_macos && echo "Running on macOS"
```

#### logging.zsh

Structured logging with multiple levels and formatting.

```zsh
lib_load logging
LOG INFO "Application started"
LOG ERROR "Failed to connect"
LOG DEBUG "Variable x = $x"
```

#### die.zsh

Error handling and graceful exit with cleanup hooks.

```zsh
lib_load die
die_if_error $? "Command failed"
assert_file "/etc/hosts" "Hosts file required"
die 1 "Fatal error occurred"
```

### Advanced Libraries

#### callstack.zsh

Stack traces, debugging utilities, and performance profiling.

```zsh
lib_load callstack
stack_trace
debug_on
profile_start "my_function"
# ... code ...
profile_end "my_function"
profile_report
```

#### cli.zsh

Command-line argument parsing with subcommands and automatic help generation.

```zsh
lib_load cli
cli_program "myapp" "My Application" "1.0.0"
cli_flag "verbose" "v" "Enable verbose output" "" "bool"
cli_flag "output" "o" "Output file" "output.txt" "string"
cli_parse_with_help "$@"
```

#### unit.zsh

Comprehensive unit testing framework with assertions and mocking.

```zsh
lib_load unit
test_suite "My Tests"
test_case "String equality" 'assert_equals "hello" "hello"'
test_case "File exists" 'assert_file_exists "/etc/hosts"'
test_summary
```

#### help.zsh

Help text and man page generation utilities.

```zsh
lib_load help
help_program "myapp" "1.0.0" "My application"
help_usage "myapp [OPTIONS] FILE"
help_options "$(build_options "h" "help" "" "Show help")"
help_display
```

#### types.zsh

Type checking and validation for safer scripting.

```zsh
lib_load types
is_int "42" && echo "Valid integer"
is_email "user@example.com" && echo "Valid email"
validate "$input" required email
assert_type "$var" "int"
```

### Utility Libraries

#### ssh.zsh

SSH connection and key management utilities.

```zsh
lib_load ssh
ssh_generate_key "my_key" "ed25519"
ssh_copy_key "server.example.com"
ssh_tunnel 8080 "internal.server" 80 "jump.host"
```

#### math.zsh

Advanced mathematical operations and calculations.

```zsh
lib_load math
add 10 20 30  # 60
sqrt 16 2     # 4.00
sin 45        # 0.7071
stddev 1 2 3 4 5
```

#### textwrap.zsh

Text formatting, wrapping, and alignment utilities.

```zsh
lib_load textwrap
wrap "Long text..." 80
center "Title" 80
text_box "Important message" 40 "double"
```

### Data Structure Libraries

#### array.zsh

Comprehensive array manipulation and operations.

```zsh
lib_load array
local -a arr=(1 2 3)
array_push arr 4 5
array_reverse arr
array_unique arr
array_map arr result 'expr $1 \* 2'
```

#### hash.zsh

Hash/dictionary operations and manipulations.

```zsh
lib_load hash
local -A data
hash_set data "name" "John"
hash_get data "name" "default"
hash_merge hash1 hash2 result
```

### Data Format Libraries

#### json.zsh

JSON parsing and generation (uses jq if available).

```zsh
lib_load json
json_object "name" "John" "age" 30
json_get "$json_data" ".user.name"
json_pretty "$json_data"
```

#### yaml.zsh

YAML parsing and generation (uses yq if available).

```zsh
lib_load yaml
local -A config
yaml_decode "$yaml_content" config
yaml_encode config
yaml_to_json "$yaml_content"
```

## Dependency Management

The library system includes automatic dependency resolution:

```zsh
# Dependencies are automatically loaded
lib_load unit  # Automatically loads colors and logging

# View dependencies
lib_show_dependencies
lib_show_dependencies unit
```

## Configuration

### Environment Variables

- `LIB_DIR` - Library directory (auto-detected)
- `LIB_VERBOSE` - Enable verbose loading messages (0/1)
- `LIB_STRICT` - Fail on missing libraries (0/1)
- `LIB_AUTOLOAD` - Auto-load core libraries (0/1)

### Example Configuration

```zsh
# In your .zshrc or script
export LIB_VERBOSE=1
export LIB_AUTOLOAD=1
source $DOTFILES_DIR/src/lib/lib.zsh
```

## Usage Examples

### Building a CLI Application

```zsh
#!/usr/bin/env zsh

source $DOTFILES_DIR/src/lib/lib.zsh
lib_load_all cli logging die

cli_program "backup" "Backup utility" "1.0.0"
cli_flag "source" "s" "Source directory" "" "string" "true"
cli_flag "dest" "d" "Destination" "" "string" "true"
cli_flag "verbose" "v" "Verbose output" "" "bool"

cli_parse_with_help "$@" || exit $?

source_dir=$(cli_get "source")
dest_dir=$(cli_get "dest")

LOG INFO "Starting backup from $source_dir to $dest_dir"

rsync -av "$source_dir" "$dest_dir" || die 1 "Backup failed"

LOG INFO "Backup completed successfully"
```

### Writing Tests

```zsh
#!/usr/bin/env zsh

source $DOTFILES_DIR/src/lib/lib.zsh
lib_load unit

test_suite "String Utils Tests"

test_case "Trim removes whitespace" '
    source $DOTFILES_DIR/src/lib/utils.zsh
    result=$(trim "  hello  ")
    assert_equals "hello" "$result"
'

test_case "Join combines array" '
    local -a arr=(one two three)
    result=$(join_array arr ", ")
    assert_equals "one, two, three" "$result"
'

test_summary
```

### SSH Automation

```zsh
#!/usr/bin/env zsh

source $DOTFILES_DIR/src/lib/lib.zsh
lib_load ssh logging

# Generate key if needed
if ! ssh_key_exists "deploy_key"; then
    LOG INFO "Generating deployment key"
    ssh_generate_key "deploy_key" "ed25519"
fi

# Copy to servers
for server in server1.example.com server2.example.com; do
    LOG INFO "Deploying key to $server"
    ssh_copy_key "$server" "deploy_key"
done

# Test connections
for server in server1.example.com server2.example.com; do
    if ssh_test_connection "$server"; then
        LOG INFO "✓ $server is accessible"
    else
        LOG ERROR "✗ Cannot connect to $server"
    fi
done
```

## Library Development

### Creating a New Library

1. Create a new file: `src/lib/mylib.zsh`
2. Add library functions with consistent naming
3. Update dependencies in `lib.zsh` if needed
4. Add documentation to this README

### Library Conventions

- Prefix functions with library name or use consistent naming
- Provide both simple and advanced interfaces
- Include error handling and validation
- Document parameters and return values
- Add usage examples in comments

### Testing Libraries

```zsh
# Test individual library
source $DOTFILES_DIR/src/lib/lib.zsh
lib_load unit mylib

test_suite "MyLib Tests"
# Add test cases
test_summary
```

## Performance Considerations

- Libraries are loaded on-demand
- Dependencies are resolved automatically
- Functions are lazy-evaluated
- External tools (jq, yq) used when available for better performance

## Compatibility

- Requires ZSH 5.0 or later
- Some features use external tools (jq, yq, bc) when available
- Falls back to pure ZSH implementations when tools are missing
- Tested on macOS and Linux

## License

Part of the dotfiles repository - see main LICENSE file.

## Contributing

Contributions welcome! Please:

1. Follow existing naming conventions
2. Add tests for new functionality
3. Update this README with examples
4. Ensure compatibility with ZSH 5.0+
