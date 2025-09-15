#!/usr/bin/env python3
"""
Sample Python file for LSP testing.
Tests diagnostics, completion, hover, and formatting.
"""

import os
import sys
from typing import List, Dict, Optional


class Calculator:
    """A simple calculator class for testing."""

    def __init__(self, initial_value: float = 0):
        self.value = initial_value
        self._history: List[float] = [initial_value]

    def add(self, amount: float) -> 'Calculator':
        """Add amount to current value."""
        self.value += amount
        self._history.append(self.value)
        return self

    def multiply(self, factor: float) -> 'Calculator':
        """Multiply current value by factor."""
        self.value *= factor
        self._history.append(self.value)
        return self

    def get_history(self) -> List[float]:
        """Return calculation history."""
        return self._history.copy()

    # Intentional error for diagnostic testing
    def bad_method(self):
        undefined_variable  # This should trigger a diagnostic
        return self.value / 0  # This too


def process_data(data: List[int],
                 processor: Optional[callable] = None) -> Dict[str, any]:
    """Process a list of integers with optional processor function."""
    if processor is None:
        processor = lambda x: x * 2

    results = {
        'original': data,
        'processed': [processor(item) for item in data],
        'sum': sum(data),
        'avg': sum(data) / len(data) if data else 0
    }

    # Test completion here: os.path.
    # Test hover on any parameter

    return results


# Formatting test - this should be reformatted
def poorly_formatted(x, y, z):
    return x + y + z


# Code action test - missing import
def use_pandas():
    df = pd.DataFrame()  # pandas not imported
    return df


if __name__ == "__main__":
    calc = Calculator(10)
    result = calc.add(5).multiply(2).get_history()
    print(f"Calculator history: {result}")

    data = [1, 2, 3, 4, 5]
    processed = process_data(data)
    print(f"Processed data: {processed}")

    # Another intentional error
    print(undefined_function())
