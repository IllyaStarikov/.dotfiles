# Demo Assets

Demo files for dotfiles gallery screenshots.

## Files

| File            | Purpose                              |
| --------------- | ------------------------------------ |
| `demo.tex`      | LaTeX demo for VimTeX showcase       |
| `demo.pdf`      | Compiled PDF (generated)             |
| `sample.py`     | Python file for fixy formatting demo |
| `sample.tar.gz` | Archive for extract demo             |

## Usage

Used by the `dot_demo` tmuxinator config:

```bash
tmuxinator start dot_demo
```

## Regenerating

```bash
# LaTeX
cd ~/.dotfiles/doc/assets
latexmk -pdf demo.tex

# Archive (after extract demo consumes it)
echo "Sample content" > sample.txt && tar -czf sample.tar.gz sample.txt && rm sample.txt
```
