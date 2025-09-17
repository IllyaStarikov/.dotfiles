# /test/fixtures - Test Data & Mock Files

## What's in this directory

This directory contains sample files and test data used across the test suite. These fixtures provide consistent, predictable inputs for testing language servers, formatters, linters, and editor functionality.

### Fixture Files:

```
fixtures/
├── sample.cpp   # C++ test file (4.2KB) - Templates, classes, STL
├── sample.js    # JavaScript file (1.9KB) - ES6+, async/await
├── sample.lua   # Lua file (1.7KB) - Neovim API, tables
├── sample.md    # Markdown file (3.8KB) - Headers, lists, code blocks
├── sample.py    # Python file (2.1KB) - Classes, type hints, errors
├── sample.rs    # Rust file (4.4KB) - Traits, lifetimes, macros
├── sample.tex   # LaTeX file (1.2KB) - Document structure, math
└── sample.ts    # TypeScript file (2.9KB) - Interfaces, generics
```

### How to use:

```bash
# In tests, reference fixtures
TEST_FILE="$TEST_DIR/fixtures/sample.py"

# Test LSP functionality
nvim --headless "$TEST_FILE" -c "lua vim.lsp.buf.hover()"

# Test formatting
fixy "$TEST_FILE" --check

# Test syntax highlighting
nvim "$TEST_FILE" -c "TSHighlightCapturesUnderCursor"
```

## Why this directory exists

Test fixtures ensure reproducibility and consistency. Real-world files change, but fixtures remain stable, allowing tests to reliably verify functionality across different environments and over time.

### Purpose of fixtures:

- **Consistent test input** - Same file, same results
- **Edge case coverage** - Intentional errors and complex syntax
- **Performance baseline** - Known file sizes for benchmarking
- **Cross-language testing** - Verify polyglot functionality
- **Regression detection** - Catch breaking changes

## Fixture Design

### Each sample file includes:

#### Language Features (`sample.py`):

```python
# 1. Import statements (for completion testing)
import os
from typing import List, Dict, Optional

# 2. Class definitions (for outline/symbols)
class Calculator:
    def __init__(self, initial_value: float = 0):
        self.value = initial_value

# 3. Type hints (for LSP testing)
def process_data(data: List[int]) -> Dict[str, any]:

# 4. Intentional errors (for diagnostic testing)
def bad_method(self):
    undefined_variable  # Should trigger diagnostic
    return self.value / 0  # Division by zero
```

#### Common Test Patterns:

**LSP Testing Elements:**

- Function definitions with docstrings
- Class hierarchies with inheritance
- Import statements for completion
- Type annotations for type checking
- Intentional errors for diagnostics

**Formatter Testing Elements:**

- Inconsistent indentation
- Long lines needing wrapping
- Mixed quotes and spacing
- Trailing whitespace
- Tab/space mixing

**Syntax Testing Elements:**

- Language-specific keywords
- Complex nested structures
- String interpolation
- Comments and documentation
- Special characters and operators

## Lessons Learned

### What NOT to Do

#### ❌ Don't use production code as fixtures

**Problem**: Customer code accidentally committed
**Solution**: Create synthetic examples

```python
# BAD: Real database credentials
connection = psycopg2.connect("dbname=prod_db user=admin password=secret123")

# GOOD: Obviously fake data
connection = psycopg2.connect("dbname=test_db user=test_user password=FAKE_PASS")
```

#### ❌ Don't make fixtures too simple

**Problem**: Tests passed but real files failed
**Solution**: Include complexity

```lua
-- Too simple
local x = 1

-- Better: Real-world patterns
local M = {}
function M.setup(opts)
    opts = vim.tbl_deep_extend("force", M.defaults, opts or {})
    return M._internal.process(opts)
end
```

#### ❌ Don't forget encoding issues

**Problem**: Tests failed on files with unicode
**Solution**: Include unicode in fixtures

```markdown
# Include emojis 🚀 and special chars: ñ, ü, 中文
```

#### ❌ Don't test only happy paths

**Problem**: Error handling never tested
**Solution**: Include intentional errors

```javascript
// Syntax error for parser testing
const broken = {

// Type error for LSP testing
const num: number = "string";

// Runtime error for debugger testing
console.log(undefinedVar.property);
```

### Fixture Requirements

1. **Size constraints** - Keep under 5KB for fast tests
2. **Self-contained** - No external dependencies
3. **Documented purpose** - Comment what each section tests
4. **Cross-platform** - Use LF line endings
5. **Version neutral** - Avoid bleeding-edge syntax

### Failed Approaches

- **Generated fixtures** - Too random, hard to debug failures
- **Minimized fixtures** - Lost real-world complexity
- **Binary fixtures** - Git diff issues, storage bloat
- **External fixtures** - Network dependency, flaky tests

### Discovered Patterns

1. **Golden files** - Expected output for comparison

   ```bash
   diff expected.txt actual.txt
   ```

2. **Error seeding** - Intentional bugs at specific lines

   ```python
   # Line 37: undefined_variable diagnostic test
   ```

3. **Feature flags** - Toggle test scenarios

   ```typescript
   const ENABLE_ASYNC_TESTS = true;
   ```

4. **Boundary testing** - Edge cases in every file
   ```rust
   let empty: Vec<i32> = vec![];  // Empty collection
   let huge = vec![0; 10000];     // Large collection
   ```

## Adding New Fixtures

When creating new fixture files:

1. **Document the purpose** at the top
2. **Include common patterns** for that language
3. **Add intentional errors** with comments
4. **Keep size reasonable** (< 5KB)
5. **Test the fixture** manually first

Template for new fixture:

```python
#!/usr/bin/env python3
"""
Fixture for testing FEATURE in LANGUAGE.
Tests: completion, diagnostics, formatting, folding
"""

# Section 1: Imports and setup
# Tests: Import completion, module resolution

# Section 2: Class/function definitions
# Tests: Outline, symbols, navigation

# Section 3: Complex logic
# Tests: Syntax highlighting, indentation

# Section 4: Intentional errors
# Tests: Diagnostics, error recovery
# ERROR: Line XX - undefined variable
# ERROR: Line YY - type mismatch
```

## Fixture Maintenance

### Validation:

```bash
# Ensure fixtures are valid
for file in fixtures/sample.*; do
    case "$file" in
        *.py) python -m py_compile "$file" ;;
        *.js) node --check "$file" ;;
        *.ts) tsc --noEmit "$file" ;;
        *.lua) luac -p "$file" ;;
    esac
done
```

### Updates:

- Review fixtures when language versions change
- Update when new LSP features added
- Expand when new test cases needed
- Prune if fixtures grow too large

## Related Documentation

- [Unit Tests](../unit/README.md) - How fixtures are used
- [LSP Tests](../functional/lsp_completion_test.sh) - LSP testing
- [Performance Tests](../performance/README.md) - Fixture benchmarks
- [Test Helpers](../lib/README.md) - Fixture utilities
