# Sample Markdown Document for LSP Testing

This document tests **marksman** LSP functionality including diagnostics, completion, and navigation.

## Table of Contents

- [Introduction](#introduction)
- [Code Examples](#code-examples)
- [Links and References](#links-and-references)
- [Common Issues](#common-issues)
- [Missing Section](#missing-section) <!-- This link should show as broken -->

## Introduction

This is a sample document with various Markdown features to test LSP functionality.

### Features to Test

1. **Bold text** and _italic text_
2. `Inline code`
3. [Internal links](#code-examples)
4. [External links](https://example.com)
5. ![Images](image.png)

## Code Examples

Here are some code blocks with syntax highlighting:

```python
def hello_world():
    print("Hello from Python!")
```

```javascript
const greet = (name) => {
  console.log(`Hello, ${name}!`);
};
```

```bash
#!/bin/bash
echo "Hello from Bash!"
```

## Links and References

### Internal References

- Link to [Introduction](#introduction)
- Link to [non-existent section](#this-does-not-exist) <!-- Should show diagnostic -->
- Link to [Code Examples](#code-examples)

### External Links

- [GitHub](https://github.com)
- [Broken link](htps://example.com) <!-- Typo in protocol -->
- Relative link to [another file](./another.md) <!-- May show as broken if file doesn't exist -->

### Reference-style Links

Here's a [reference link][1] and another [reference][label].

[1]: https://example.com 'Example Site'
[label]: https://github.com 'GitHub'

[unused]: https://unused.com "This reference is not used" <!-- Might show warning -->

## Common Issues

### Unordered List Issues

- Item 1
- Item 2
  - Nested item
    - Double nested
- Item 3

* Mixed bullet style <!-- Inconsistent list markers -->

- Back to dashes

### Ordered List Issues

1. First item
2. Second item
3. Third item <!-- Incorrect numbering -->
4. Fourth item

### Table Formatting

| Header 1 | Header 2 | Header 3 |
| -------- | -------- | -------- | --------------------- | ------------------- |
| Cell 1   | Cell 2   | Cell 3   |
| Cell 4   | Cell 5   |          | <!-- Missing cell --> |
| Cell 7   | Cell 8   | Cell 9   | Extra cell            | <!-- Extra cell --> |

### Incomplete Formatting

This is \**bold but not closed
This is *italic but not closed
This is `code but not closed

### Task Lists

- [x] Completed task
- [ ] Incomplete task
- [x] Another completed task <!-- Uppercase X -->
- [] Missing space <!-- Incorrect format -->

## Heading Issues

### Duplicate Heading <!-- This heading appears twice -->

Some content here.

### Duplicate Heading <!-- Duplicate -->

More content here.

####No space after hashes <!-- Missing space -->

## Front Matter

---

title: Sample Document
author: Test Author
tags: [markdown, lsp, testing]

---

## Footnotes

Here's a sentence with a footnote[^1].

[^1]: This is the footnote text.

[^2]: This footnote is not referenced. <!-- Unused footnote -->

Here's another reference[^3] to a missing footnote. <!-- Missing footnote -->

## HTML in Markdown

<div>
  <p>Some HTML content</p>
  <img src="image.jpg" alt="Image">
  <br>  <!-- Self-closing tag -->
</div>

<script>alert('This should probably be flagged');</script>  <!-- Potentially dangerous -->

## Special Characters and Escaping

- Email: user@example.com
- URL: https://example.com/path?query=value&other=123
- Escaped characters: \*not italic\* \[not a link\]\(url\)
- Special chars: & < > " '

## Empty Sections

###

### <!-- Only whitespace -->

## Conclusion

This document includes various Markdown elements that should trigger different LSP features:

- Diagnostics for broken links
- Warnings for style issues
- Completion for link references
- Navigation between sections

<!-- Missing newline at end of file -->
