#!/usr/bin/env python3
"""Test script for code execution."""

def main() -> int:
    """
    Main function entry point.

    Returns:
        int: Exit code (0 for success, non-zero for failure)
    """
    try:
        print("Hello from Python!")
        print("Code execution is working!")
        return 0
    except KeyboardInterrupt:
        print("Interrupted by user")
        return 130
    except Exception as e:
        print(f"Error: {e}")
        return 1


if __name__ == "__main__":
    import sys
    sys.exit(main())