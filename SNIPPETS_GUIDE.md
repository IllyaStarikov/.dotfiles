# 📚 Snippets Guide

A comprehensive guide to all available snippets in your Neovim configuration.

## Table of Contents

- [Python Snippets](#python-snippets)
- [JavaScript/TypeScript Snippets](#javascripttypescript-snippets)
- [Markdown Snippets](#markdown-snippets)
- [C/C++ Snippets](#cc-snippets)
- [HTML Snippets](#html-snippets)
- [Java Snippets](#java-snippets)
- [Shell Script Snippets](#shell-script-snippets)
- [LaTeX Snippets](#latex-snippets)

## How to Use

1. Type the snippet trigger in insert mode
2. Press `Tab` to expand the snippet
3. Use `Tab` and `Shift+Tab` to navigate between placeholders
4. Type to replace placeholder text

## Python Snippets

### `header` - Complete Module Header
```python
#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Module: [module_name]

[Brief description]

Authors:
    Your Name (email@example.com)

Created: 2024-01-15
Copyright (c) 2024, Your Name. All rights reserved.
"""
```

### `main` - Main Function with Argparse
```python
def main(argv: Sequence[str]) -> None:
    """Main entry point."""
    # Application logic
```

### `class` - Google Style Class
```python
class ClassName:
    """Brief description.
    
    Attributes:
        attribute: Description
    """
```

### `def` - Function with Full Documentation
```python
def function_name(param: str) -> str:
    """Brief description.
    
    Args:
        param: Description
        
    Returns:
        Description
        
    Raises:
        ValueError: If invalid
    """
```

### `async` - Async Function
```python
async def async_function(param: str) -> str:
    """Async function description."""
    await asyncio.sleep(0.1)
    return result
```

### `dataclass` - Modern Dataclass
```python
@dataclass(frozen=True)
class DataClass:
    """Data class with validation."""
    name: str
    value: int
```

### `property` - Property with Setter
```python
@property
def property_name(self) -> str:
    """Get property."""
    return self._property_name

@property_name.setter
def property_name(self, value: str) -> None:
    """Set property with validation."""
```

### `test` - Pytest Test Suite
```python
class TestFeature:
    """Test suite with fixtures."""
    
    @pytest.fixture
    def sample_data(self):
        return {'key': 'value'}
```

### `cli` - CLI Application
```python
def create_parser() -> argparse.ArgumentParser:
    """Create argument parser."""
    parser = argparse.ArgumentParser(
        description='Application description'
    )
```

### `fastapi` - FastAPI Endpoint
```python
@app.post('/endpoint', response_model=ResponseModel)
async def endpoint_function(request: RequestModel):
    """API endpoint with validation."""
```

### `context` - Context Manager
```python
class ResourceManager:
    """Context manager for resources."""
    def __enter__(self):
        # Acquire resource
    def __exit__(self, exc_type, exc_val, exc_tb):
        # Release resource
```

### Quick Snippets
- `ifmain` - if __name__ == '__main__'
- `import` - from module import function
- `pdb` - import pdb; pdb.set_trace()

## JavaScript/TypeScript Snippets

### `rfc` - React Functional Component
```typescript
interface ComponentProps {
  title: string;
  children?: React.ReactNode;
}

export const Component: React.FC<ComponentProps> = ({ title, children }) => {
  const [state, setState] = useState('');
  
  return (
    <div className={styles.container}>
      <h1>{title}</h1>
      {children}
    </div>
  );
};
```

### `hook` - Custom React Hook
```typescript
export const useCustomHook = (options: UseCustomHookOptions = {}): UseCustomHookReturn => {
  const [value, setValue] = useState(options.initialValue ?? '');
  
  const reset = useCallback(() => {
    setValue(initialValue);
  }, [initialValue]);
  
  return { value, setValue, reset };
};
```

### `express` - Express.js Endpoint
```typescript
export const create = async (
  req: CreateRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    // Validation
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      throw new AppError('Validation failed', 400);
    }
    
    // Business logic
    const result = await service.create(req.body);
    
    res.status(201).json({
      success: true,
      data: result
    });
  } catch (error) {
    next(error);
  }
};
```

### `test` - Jest Test Suite
```typescript
describe('functionToTest', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });
  
  it('should return expected result', async () => {
    // Arrange
    const input = 'test';
    
    // Act
    const result = await functionToTest(input);
    
    // Assert
    expect(result).toBe(expected);
  });
});
```

### `slice` - Redux Toolkit Slice
```typescript
const featureSlice = createSlice({
  name: 'feature',
  initialState,
  reducers: {
    setData(state, action) {
      state.data = action.payload;
    }
  }
});
```

### Quick Snippets
- `cl` - console.log()
- `imp` - import statement
- `exp` - export statement
- `arr` - array declaration
- `obj` - object declaration
- `des` - destructuring
- `promise` - new Promise()
- `map` - array.map()
- `filter` - array.filter()
- `reduce` - array.reduce()

## Markdown Snippets

### `design_doc` - Comprehensive Design Document
Complete template for technical design documents including:
- Executive summary
- Background and context
- Goals and non-goals
- Technical architecture
- Implementation plan
- Testing strategy
- Security considerations
- Rollout plan

### `readme` - Professional README
GitHub-ready README with:
- Badges and shields
- Feature list
- Installation instructions
- Usage examples
- API documentation
- Contributing guidelines

### `api_doc` - API Documentation
REST API documentation template with:
- Authentication details
- Rate limiting info
- Endpoint specifications
- Request/response examples
- Error codes

### `pr_template` - Pull Request Template
Structured PR template with:
- Change type checkboxes
- Testing checklist
- Related issues
- Screenshots section

### `meeting` - Meeting Notes
Professional meeting notes with:
- Attendees list
- Agenda items
- Discussion points
- Action items table
- Next steps

### `blog` - Technical Blog Post
SEO-optimized blog post template with:
- Front matter metadata
- Introduction hook
- Problem/solution structure
- Code examples
- Conclusion and CTA

### `roadmap` - Project Roadmap
Visual project roadmap with:
- Milestones
- Version planning
- Feature tracking
- Release process

### `review` - Code Review Checklist
Comprehensive review template covering:
- Functionality
- Code quality
- Testing
- Documentation
- Performance
- Security

### Quick Snippets
- `link` - [text](url)
- `img` - ![alt](url "title")
- `code` - ```language code block
- `task` - - [ ] task item
- `table` - markdown table
- `details` - collapsible section
- `badge` - shield/badge

## C/C++ Snippets

### Available Snippets
- `main` - main function
- `inc` - #include statement
- `def` - #define macro
- `ifdef` - conditional compilation
- `struct` - structure definition
- `class` - C++ class
- `for` - for loop
- `while` - while loop
- `if` - if statement
- `func` - function definition

## HTML Snippets

### Available Snippets
- `html5` - HTML5 boilerplate
- `div` - div with class
- `a` - anchor tag
- `img` - image tag
- `form` - form structure
- `input` - input field
- `button` - button element
- `script` - script tag
- `style` - style tag
- `meta` - meta tags

## Java Snippets

### Available Snippets
- `main` - main method
- `class` - class definition
- `interface` - interface definition
- `method` - method with JavaDoc
- `constructor` - constructor
- `getter` - getter method
- `setter` - setter method
- `try` - try-catch block
- `for` - enhanced for loop
- `test` - JUnit test

## Shell Script Snippets

### Available Snippets
- `bash` - bash shebang
- `if` - if statement
- `elif` - elif statement
- `for` - for loop
- `while` - while loop
- `case` - case statement
- `func` - function definition
- `args` - argument parsing
- `trap` - trap signals
- `usage` - usage function

## LaTeX Snippets

### Available Snippets
- `doc` - document template
- `sec` - section
- `subsec` - subsection
- `eq` - equation
- `fig` - figure
- `tab` - table
- `item` - itemize
- `enum` - enumerate
- `ref` - reference
- `cite` - citation

## Tips and Tricks

1. **Nested Snippets**: Some snippets can be used inside others
2. **Smart Defaults**: Many snippets auto-fill based on filename or context
3. **Choice Nodes**: Use `Ctrl+n/p` to cycle through options in choice nodes
4. **Custom Variables**: Snippets use git config for author name/email
5. **Live Updates**: Function nodes update as you type

## Customization

To add your own snippets:

1. Edit the appropriate file in `~/.dotfiles/src/snippets/`
2. Follow the LuaSnip syntax
3. Reload Neovim or run `:source %`

## Best Practices

1. Use descriptive snippet names
2. Keep snippets focused and single-purpose
3. Include documentation in complex snippets
4. Use placeholders for all variable parts
5. Provide sensible defaults where possible