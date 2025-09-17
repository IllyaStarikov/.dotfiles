# Performance Tests

Ensures dotfiles remain fast with regression testing and benchmarks.

## Test Files

- `benchmarks.zsh` - Core metrics
- `comprehensive_performance_test.sh` - Full suite
- `performance_test.sh` - Quick checks

## Performance Standards

- **Neovim startup**: < 300ms
- **Zsh init**: < 500ms
- **Theme switch**: < 500ms
- **Plugin load**: < 500ms
- **Memory**: < 200MB

## Running Tests

```bash
./test/test --performance          # Quick performance check
./test/performance/comprehensive_performance_test.sh  # Full benchmarks
./test/test --performance --baseline  # Compare with baseline
```

## Key Metrics

### Neovim Startup (280ms on M1)

```
Base Neovim:        20ms
Core config:        30ms
Plugin manager:     40ms
LSP setup:          50ms
Treesitter:         60ms
Theme/UI:           40ms
Keymaps:            20ms
Autocommands:       20ms
```

### Optimizations Applied

- **Lazy loading**: Saved 500ms (was 900ms)
- **Provider disable**: Saved 70ms
- **Async clipboard**: Saved 30ms
- **Compiled regex**: Saved 20ms

## Testing Best Practices

### Accurate Measurements

```bash
# Warm up caches first
nvim --headless -c "qa!"
# Then measure
nvim --startuptime log.txt -c "qa!"
```

### Multiple Iterations

Run 5-10 times and use median, not average (outliers skew results).

### Power State Matters

Tests on battery power are throttled - plug in for consistent results.

## Common Issues

**Debug mode affects timing**: Ensure `DEBUG`, `NVIM_DEBUG` unset.

**Cold cache penalties**: First run always slower - warm up before measuring.

**Background processes**: Close other apps for accurate results.

## Regression Prevention

- Baseline recorded in CI
- 10% degradation triggers alert
- Performance tracked over time
- Every optimization documented

Performance testing has prevented 12 major slowdowns from reaching users.
