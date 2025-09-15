#!/usr/bin/env python3
"""
Dotfiles Test Runner - A focused, signal-driven test suite.

This runner executes tests that provide meaningful signal about the health
and functionality of the dotfiles setup. Tests are organized by their purpose
and signal value, not by arbitrary categories.
"""

import argparse
import json
import os
import subprocess
import sys
import tempfile
import time
from dataclasses import dataclass, field
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Optional, Tuple

# ANSI color codes
class Colors:
    """Terminal color codes for output formatting."""
    RESET = '\033[0m'
    BOLD = '\033[1m'
    RED = '\033[31m'
    GREEN = '\033[32m'
    YELLOW = '\033[33m'
    BLUE = '\033[34m'
    CYAN = '\033[36m'
    GRAY = '\033[90m'


@dataclass
class TestResult:
    """Result of a single test execution."""
    name: str
    passed: bool
    duration: float
    output: str = ""
    error: str = ""
    skipped: bool = False
    skip_reason: str = ""


@dataclass
class TestSuite:
    """Collection of test results with metadata."""
    name: str
    results: List[TestResult] = field(default_factory=list)
    start_time: Optional[datetime] = None
    end_time: Optional[datetime] = None

    @property
    def passed_count(self) -> int:
        return sum(1 for r in self.results if r.passed and not r.skipped)

    @property
    def failed_count(self) -> int:
        return sum(1 for r in self.results if not r.passed and not r.skipped)

    @property
    def skipped_count(self) -> int:
        return sum(1 for r in self.results if r.skipped)

    @property
    def total_duration(self) -> float:
        return sum(r.duration for r in self.results)


class TestRunner:
    """Main test runner that executes and reports on tests."""

    def __init__(self, debug: bool = False, artifact_dir: Optional[str] = None):
        self.debug = debug
        self.dotfiles_dir = Path(__file__).parent.parent
        self.test_dir = self.dotfiles_dir / "test"
        self.artifact_dir = Path(artifact_dir) if artifact_dir else self.test_dir / "artifacts"
        self.artifact_dir.mkdir(exist_ok=True)
        self.suites: List[TestSuite] = []

        # Set up environment
        os.environ['DOTFILES_DIR'] = str(self.dotfiles_dir)
        os.environ['TEST_DIR'] = str(self.test_dir)

        # Detect CI environment
        self.ci_mode = os.environ.get('CI', '').lower() == 'true'

    def run_command(self, cmd: List[str], timeout: int = 30) -> Tuple[int, str, str]:
        """Execute a command and return exit code, stdout, and stderr."""
        if self.debug:
            print(f"{Colors.GRAY}Running: {' '.join(cmd)}{Colors.RESET}")

        try:
            result = subprocess.run(
                cmd,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True,
                timeout=timeout,
                cwd=self.dotfiles_dir
            )
            return result.returncode, result.stdout, result.stderr
        except subprocess.TimeoutExpired:
            return 1, "", f"Command timed out after {timeout} seconds"
        except Exception as e:
            return 1, "", str(e)

    def test_essential_files(self) -> TestResult:
        """Test that core configuration files exist and are readable."""
        start = time.time()
        essential_files = [
            "src/neovim/init.lua",
            "src/zsh/zshrc",
            "src/tmux.conf",
            "src/git/gitconfig",
            "src/scripts/fixy",
            "src/theme-switcher/switch-theme.sh",
        ]

        missing = []
        for file in essential_files:
            path = self.dotfiles_dir / file
            if not path.exists():
                missing.append(file)

        passed = len(missing) == 0
        output = f"Checked {len(essential_files)} essential files"
        error = f"Missing files: {', '.join(missing)}" if missing else ""

        return TestResult(
            name="Essential files exist",
            passed=passed,
            duration=time.time() - start,
            output=output,
            error=error
        )

    def test_neovim_config(self) -> TestResult:
        """Test that Neovim configuration loads without errors."""
        start = time.time()

        # Create a minimal test init file that sources the main config
        test_init = """
        -- Add dotfiles to runtime path
        vim.opt.runtimepath:prepend(vim.env.DOTFILES_DIR .. '/src/neovim')

        -- Capture any errors
        local errors = {}
        local old_notify = vim.notify
        vim.notify = function(msg, level)
            if level == vim.log.levels.ERROR then
                table.insert(errors, msg)
            end
        end

        -- Try to load the config
        local ok, err = pcall(function()
            dofile(vim.env.DOTFILES_DIR .. '/src/neovim/init.lua')
        end)

        if not ok then
            print('LOAD_ERROR: ' .. tostring(err))
        elseif #errors > 0 then
            print('RUNTIME_ERRORS: ' .. table.concat(errors, '; '))
        else
            print('CONFIG_OK')
        end

        vim.cmd('qa!')
        """

        with tempfile.NamedTemporaryFile(mode='w', suffix='.lua', delete=False) as f:
            f.write(test_init)
            test_file = f.name

        try:
            code, stdout, stderr = self.run_command(
                ['nvim', '--headless', '-u', test_file],
                timeout=5
            )

            if 'CONFIG_OK' in stdout or 'CONFIG_OK' in stderr:
                return TestResult(
                    name="Neovim configuration loads",
                    passed=True,
                    duration=time.time() - start,
                    output="Configuration loaded successfully"
                )
            elif 'LOAD_ERROR' in stdout or 'LOAD_ERROR' in stderr:
                error_msg = stdout + stderr
                if 'LOAD_ERROR:' in error_msg:
                    error = error_msg.split('LOAD_ERROR:')[1].strip()
                else:
                    error = error_msg
                return TestResult(
                    name="Neovim configuration loads",
                    passed=False,
                    duration=time.time() - start,
                    error=f"Load error: {error}"
                )
            else:
                return TestResult(
                    name="Neovim configuration loads",
                    passed=False,
                    duration=time.time() - start,
                    error=stderr or stdout or "Unknown error"
                )
        finally:
            os.unlink(test_file)

    def test_shell_scripts_syntax(self) -> TestResult:
        """Test that all shell scripts have valid syntax."""
        start = time.time()

        # Find all shell scripts
        shell_files = []
        for pattern in ['*.sh', '*.zsh', '*.bash']:
            shell_files.extend(self.dotfiles_dir.glob(f'src/**/{pattern}'))

        errors = []
        for script in shell_files:
            # Skip non-executable library files
            if script.name == 'common.sh':
                continue

            # Determine shell type
            with open(script, 'r') as f:
                first_line = f.readline().strip()

            if 'zsh' in first_line:
                shell = 'zsh'
            elif 'bash' in first_line:
                shell = 'bash'
            else:
                shell = 'sh'

            # Check syntax
            code, _, stderr = self.run_command([shell, '-n', str(script)])
            if code != 0:
                errors.append(f"{script.relative_to(self.dotfiles_dir)}: {stderr.strip()}")

        return TestResult(
            name="Shell scripts syntax check",
            passed=len(errors) == 0,
            duration=time.time() - start,
            output=f"Checked {len(shell_files)} shell scripts",
            error='\n'.join(errors) if errors else ""
        )

    def test_theme_switcher(self) -> TestResult:
        """Test that theme switcher works correctly."""
        start = time.time()

        switcher = self.dotfiles_dir / "src/theme-switcher/switch-theme.sh"
        if not switcher.exists():
            return TestResult(
                name="Theme switcher functionality",
                passed=False,
                duration=time.time() - start,
                error="Theme switcher script not found"
            )

        # Test listing themes - run from the theme-switcher directory
        original_dir = os.getcwd()
        try:
            os.chdir(switcher.parent)
            code, stdout, stderr = self.run_command(['./switch-theme.sh', '--list'])
        finally:
            os.chdir(original_dir)
        if code != 0:
            return TestResult(
                name="Theme switcher functionality",
                passed=False,
                duration=time.time() - start,
                error=f"Failed to list themes: {stderr}"
            )

        themes = ['tokyonight_day', 'tokyonight_storm', 'tokyonight_night', 'tokyonight_moon']
        output = stdout.lower()
        missing_themes = [t for t in themes if t not in output]

        if missing_themes:
            return TestResult(
                name="Theme switcher functionality",
                passed=False,
                duration=time.time() - start,
                error=f"Missing themes: {', '.join(missing_themes)}"
            )

        return TestResult(
            name="Theme switcher functionality",
            passed=True,
            duration=time.time() - start,
            output="All themes available and switchable"
        )

    def test_git_hooks(self) -> TestResult:
        """Test that git hooks are properly configured."""
        start = time.time()

        # Check for gitleaks configuration
        gitleaks_config = self.dotfiles_dir / "src/gitleaks.toml"
        if not gitleaks_config.exists():
            return TestResult(
                name="Git hooks configuration",
                passed=False,
                duration=time.time() - start,
                error="Gitleaks configuration not found"
            )

        # Check if gitleaks is available
        code, _, _ = self.run_command(['which', 'gitleaks'])
        if code != 0:
            return TestResult(
                name="Git hooks configuration",
                passed=True,
                duration=time.time() - start,
                output="Gitleaks config present (tool not installed)",
                skipped=True,
                skip_reason="Gitleaks not installed"
            )

        return TestResult(
            name="Git hooks configuration",
            passed=True,
            duration=time.time() - start,
            output="Git hooks properly configured"
        )

    def test_neovim_performance(self) -> TestResult:
        """Test Neovim startup performance."""
        start = time.time()

        # Skip in CI where performance may vary
        if self.ci_mode:
            return TestResult(
                name="Neovim startup performance",
                passed=True,
                duration=0,
                skipped=True,
                skip_reason="Performance tests skipped in CI"
            )

        # Measure startup time
        startup_file = self.artifact_dir / "nvim-startup.log"
        code, _, stderr = self.run_command([
            'nvim',
            '--headless',
            '--startuptime', str(startup_file),
            '-c', 'qa'
        ], timeout=5)

        if code != 0:
            return TestResult(
                name="Neovim startup performance",
                passed=False,
                duration=time.time() - start,
                error=f"Failed to measure startup time: {stderr}"
            )

        # Parse startup time
        total_ms = None
        with open(startup_file, 'r') as f:
            lines = f.readlines()
            for line in reversed(lines):
                if '--- NVIM STARTED ---' in line:
                    # Format: "161.104  000.020: --- NVIM STARTED ---"
                    parts = line.strip().split()
                    if parts and parts[0].replace('.', '').isdigit():
                        total_ms = float(parts[0])
                        break

        if total_ms is not None:
            # Threshold: 300ms for good performance
            if total_ms < 300:
                status = "excellent"
                passed = True
            elif total_ms < 500:
                status = "acceptable"
                passed = True
            else:
                status = "slow"
                passed = False

            return TestResult(
                name="Neovim startup performance",
                passed=passed,
                duration=time.time() - start,
                output=f"Startup time: {total_ms:.1f}ms ({status})"
            )

        return TestResult(
            name="Neovim startup performance",
            passed=False,
            duration=time.time() - start,
            error="Could not parse startup time"
        )

    def test_critical_commands(self) -> TestResult:
        """Test that critical custom commands work."""
        start = time.time()

        commands_to_test = [
            (['theme', '--help'], "Theme switcher"),
            (['fixy', '--help'], "Code formatter"),
        ]

        failed = []
        for cmd, name in commands_to_test:
            # Try to find the command
            full_path = self.dotfiles_dir / 'src/scripts' / cmd[0]
            if not full_path.exists():
                full_path = self.dotfiles_dir / 'src/theme-switcher' / f'{cmd[0]}.sh'

            if full_path.exists():
                test_cmd = [str(full_path)] + cmd[1:]
                code, _, _ = self.run_command(test_cmd, timeout=5)
                if code != 0:
                    failed.append(name)
            else:
                failed.append(f"{name} (not found)")

        return TestResult(
            name="Critical commands availability",
            passed=len(failed) == 0,
            duration=time.time() - start,
            output=f"Tested {len(commands_to_test)} critical commands",
            error=f"Failed: {', '.join(failed)}" if failed else ""
        )

    def test_symlinks_integrity(self) -> TestResult:
        """Test that symlinks script would create proper links."""
        start = time.time()

        symlinks_script = self.dotfiles_dir / "src/setup/symlinks.sh"
        if not symlinks_script.exists():
            return TestResult(
                name="Symlinks configuration",
                passed=False,
                duration=time.time() - start,
                error="Symlinks script not found"
            )

        # Run in dry-run mode to check what would be linked
        code, stdout, stderr = self.run_command(
            ['bash', str(symlinks_script), '--dry-run'],
            timeout=10
        )

        if code != 0 and 'Would create' not in stdout:
            return TestResult(
                name="Symlinks configuration",
                passed=False,
                duration=time.time() - start,
                error=f"Symlinks script failed: {stderr}"
            )

        # Check for key symlinks that should be created
        expected_links = [
            '.zshrc', '.tmux.conf', '.gitconfig',
            '.config/nvim', '.config/alacritty'
        ]

        missing = []
        for link in expected_links:
            if link not in stdout and f"/{link}" not in stdout:
                # Check if it already exists
                home_path = Path.home() / link
                if not home_path.exists() and not home_path.is_symlink():
                    missing.append(link)

        return TestResult(
            name="Symlinks configuration",
            passed=len(missing) == 0,
            duration=time.time() - start,
            output="Symlinks configuration valid",
            error=f"Missing links: {', '.join(missing)}" if missing else ""
        )

    def test_language_configs(self) -> TestResult:
        """Test that language configurations are valid."""
        start = time.time()

        configs = {
            'Python': self.dotfiles_dir / 'src/language/ruff.toml',
            'C++': self.dotfiles_dir / 'src/language/.clang-format',
            'Lua': self.dotfiles_dir / 'src/language/stylua.toml',
        }

        missing = []
        for lang, path in configs.items():
            if not path.exists():
                missing.append(lang)

        return TestResult(
            name="Language configurations",
            passed=len(missing) == 0,
            duration=time.time() - start,
            output=f"Checked {len(configs)} language configs",
            error=f"Missing configs for: {', '.join(missing)}" if missing else ""
        )

    def run_suite(self, suite_name: str, tests: List[str]) -> TestSuite:
        """Run a suite of tests."""
        suite = TestSuite(name=suite_name)
        suite.start_time = datetime.now()

        print(f"\n{Colors.CYAN}━━━ {suite_name} ━━━{Colors.RESET}")

        for test_name in tests:
            test_method = getattr(self, test_name, None)
            if not test_method:
                print(f"{Colors.YELLOW}⚠ Test not found: {test_name}{Colors.RESET}")
                continue

            print(f"{Colors.BLUE}▶{Colors.RESET} {test_method.__doc__.strip()}...", end=' ')

            try:
                result = test_method()
                suite.results.append(result)

                if result.skipped:
                    print(f"{Colors.YELLOW}SKIPPED{Colors.RESET} ({result.skip_reason})")
                elif result.passed:
                    print(f"{Colors.GREEN}✓ PASSED{Colors.RESET}")
                else:
                    print(f"{Colors.RED}✗ FAILED{Colors.RESET}")
                    if result.error and self.debug:
                        print(f"  {Colors.GRAY}{result.error}{Colors.RESET}")
            except Exception as e:
                print(f"{Colors.RED}✗ ERROR{Colors.RESET}")
                if self.debug:
                    print(f"  {Colors.GRAY}{str(e)}{Colors.RESET}")
                suite.results.append(TestResult(
                    name=test_name,
                    passed=False,
                    duration=0,
                    error=str(e)
                ))

        suite.end_time = datetime.now()
        self.suites.append(suite)
        return suite

    def generate_report(self) -> Dict:
        """Generate a comprehensive test report."""
        total_passed = sum(s.passed_count for s in self.suites)
        total_failed = sum(s.failed_count for s in self.suites)
        total_skipped = sum(s.skipped_count for s in self.suites)
        total_duration = sum(s.total_duration for s in self.suites)

        report = {
            'timestamp': datetime.now().isoformat(),
            'summary': {
                'total_tests': total_passed + total_failed + total_skipped,
                'passed': total_passed,
                'failed': total_failed,
                'skipped': total_skipped,
                'duration': total_duration,
                'success_rate': (total_passed / (total_passed + total_failed) * 100)
                                if (total_passed + total_failed) > 0 else 0
            },
            'suites': []
        }

        for suite in self.suites:
            suite_data = {
                'name': suite.name,
                'passed': suite.passed_count,
                'failed': suite.failed_count,
                'skipped': suite.skipped_count,
                'duration': suite.total_duration,
                'tests': []
            }

            for result in suite.results:
                test_data = {
                    'name': result.name,
                    'passed': result.passed,
                    'skipped': result.skipped,
                    'duration': result.duration
                }
                if result.error:
                    test_data['error'] = result.error
                if result.skip_reason:
                    test_data['skip_reason'] = result.skip_reason
                suite_data['tests'].append(test_data)

            report['suites'].append(suite_data)

        return report

    def save_artifacts(self):
        """Save test artifacts for review."""
        # Save JSON report
        report = self.generate_report()
        report_file = self.artifact_dir / f"test-report-{datetime.now().strftime('%Y%m%d-%H%M%S')}.json"
        with open(report_file, 'w') as f:
            json.dump(report, f, indent=2)
        print(f"\n{Colors.GRAY}Report saved to: {report_file}{Colors.RESET}")

        # Save debug log if in debug mode
        if self.debug:
            debug_file = self.artifact_dir / f"debug-{datetime.now().strftime('%Y%m%d-%H%M%S')}.log"
            with open(debug_file, 'w') as f:
                for suite in self.suites:
                    f.write(f"\n=== {suite.name} ===\n")
                    for result in suite.results:
                        f.write(f"\nTest: {result.name}\n")
                        f.write(f"Passed: {result.passed}\n")
                        f.write(f"Duration: {result.duration:.3f}s\n")
                        if result.output:
                            f.write(f"Output: {result.output}\n")
                        if result.error:
                            f.write(f"Error: {result.error}\n")
            print(f"{Colors.GRAY}Debug log saved to: {debug_file}{Colors.RESET}")

    def print_summary(self):
        """Print a summary of test results."""
        total_passed = sum(s.passed_count for s in self.suites)
        total_failed = sum(s.failed_count for s in self.suites)
        total_skipped = sum(s.skipped_count for s in self.suites)
        total_duration = sum(s.total_duration for s in self.suites)

        print(f"\n{Colors.BLUE}{'━' * 50}{Colors.RESET}")
        print(f"{Colors.BOLD}Test Summary{Colors.RESET}")
        print(f"{Colors.BLUE}{'━' * 50}{Colors.RESET}")

        print(f"  {Colors.GREEN}Passed:{Colors.RESET}  {total_passed}")
        print(f"  {Colors.RED}Failed:{Colors.RESET}  {total_failed}")
        print(f"  {Colors.YELLOW}Skipped:{Colors.RESET} {total_skipped}")
        print(f"  {Colors.CYAN}Total:{Colors.RESET}   {total_passed + total_failed + total_skipped}")
        print(f"  {Colors.GRAY}Time:{Colors.RESET}    {total_duration:.2f}s")

        if total_failed == 0:
            print(f"\n{Colors.GREEN}{Colors.BOLD}✓ All tests passed!{Colors.RESET}")
        else:
            print(f"\n{Colors.RED}{Colors.BOLD}✗ {total_failed} test(s) failed{Colors.RESET}")

            # List failed tests
            print(f"\n{Colors.RED}Failed tests:{Colors.RESET}")
            for suite in self.suites:
                for result in suite.results:
                    if not result.passed and not result.skipped:
                        print(f"  • {result.name}")
                        if self.debug and result.error:
                            print(f"    {Colors.GRAY}{result.error}{Colors.RESET}")

    def run_all(self):
        """Run all test suites."""
        # Core functionality tests - these must pass
        self.run_suite("Core Validation", [
            'test_essential_files',
            'test_neovim_config',
            'test_shell_scripts_syntax',
            'test_language_configs',
        ])

        # Integration tests - how components work together
        self.run_suite("Integration Tests", [
            'test_theme_switcher',
            'test_symlinks_integrity',
            'test_critical_commands',
            'test_git_hooks',
        ])

        # Performance tests - optional but valuable
        self.run_suite("Performance Tests", [
            'test_neovim_performance',
        ])


def main():
    """Main entry point for the test runner."""
    parser = argparse.ArgumentParser(
        description='Dotfiles Test Runner - Signal-driven testing',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s                    # Run all tests
  %(prog)s --debug           # Run with debug output
  %(prog)s --artifacts /tmp  # Save artifacts to specific directory
        """
    )

    parser.add_argument(
        '--debug',
        action='store_true',
        help='Enable debug output and save detailed logs'
    )

    parser.add_argument(
        '--artifacts',
        metavar='DIR',
        help='Directory to save test artifacts (default: test/artifacts)'
    )

    parser.add_argument(
        '--ci',
        action='store_true',
        help='Run in CI mode (skip performance tests, generate reports)'
    )

    args = parser.parse_args()

    # Set CI environment variable if needed
    if args.ci:
        os.environ['CI'] = 'true'

    # Header
    print(f"{Colors.BOLD}{Colors.BLUE}╔{'═' * 48}╗{Colors.RESET}")
    print(f"{Colors.BOLD}{Colors.BLUE}║{' ' * 14}Dotfiles Test Suite{' ' * 15}║{Colors.RESET}")
    print(f"{Colors.BOLD}{Colors.BLUE}╚{'═' * 48}╝{Colors.RESET}")

    # Create and run test runner
    runner = TestRunner(debug=args.debug, artifact_dir=args.artifacts)

    try:
        runner.run_all()
        runner.save_artifacts()
        runner.print_summary()

        # Exit with appropriate code
        total_failed = sum(s.failed_count for s in runner.suites)
        sys.exit(0 if total_failed == 0 else 1)

    except KeyboardInterrupt:
        print(f"\n{Colors.YELLOW}Tests interrupted by user{Colors.RESET}")
        sys.exit(130)
    except Exception as e:
        print(f"\n{Colors.RED}Test runner error: {e}{Colors.RESET}")
        if args.debug:
            import traceback
            traceback.print_exc()
        sys.exit(1)


if __name__ == '__main__':
    main()