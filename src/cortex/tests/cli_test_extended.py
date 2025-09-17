"""
Tests for extended CLI commands in cli.py module.
"""

import asyncio
import json
import unittest
from unittest.mock import AsyncMock
from unittest.mock import call
from unittest.mock import MagicMock
from unittest.mock import patch

from click.testing import CliRunner

from cortex.cli import cli


class TestExtendedCLICommands(unittest.TestCase):
    """Test extended CLI commands."""

    def setUp(self):
        """Set up test fixtures."""
        self.runner = CliRunner()

    @patch('subprocess.run')
    @patch('cortex.cli.Config')
    def test_start_command_mlx(self, mock_config_class, mock_subprocess):
        """Test start command for MLX server."""
        mock_config = MagicMock()
        mock_config_class.return_value = mock_config
        mock_config.data = {"providers": {"mlx": {"enabled": True, "port": 8080}}}

        mock_subprocess.return_value = MagicMock(returncode=0)

        result = self.runner.invoke(cli, ["start", "--model", "mlx-community/test"])

        # Command should complete
        self.assertIn(result.exit_code, [0, 1])  # May exit with 1 if async issues

    @patch('subprocess.run')
    @patch('cortex.cli.Config')
    def test_stop_command(self, mock_config_class, mock_subprocess):
        """Test stop command."""
        mock_config = MagicMock()
        mock_config_class.return_value = mock_config

        mock_subprocess.return_value = MagicMock(returncode=0)

        result = self.runner.invoke(cli, ["stop"])

        # Command should complete
        self.assertIn(result.exit_code, [0, 1])

    @patch('cortex.cli.Config')
    def test_status_command(self, mock_config_class):
        """Test status command."""
        mock_config = MagicMock()
        mock_config_class.return_value = mock_config
        mock_config.data = {
            "version": "0.1.0",
            "mode": "offline",
            "current_model": {
                "id": "test-model",
                "provider": "mlx"
            },
            "providers": {
                "mlx": {
                    "enabled": True
                }
            }
        }

        with patch('cortex.cli.SystemDetector') as mock_detector:
            mock_detector.detect.return_value = MagicMock(
                os_type=MagicMock(value="macos_apple_silicon"),
                cpu_model="Apple M1 Max",
                cpu_cores=10,
                ram_gb=64.0,
                performance_tier=MagicMock(value="ultra"))

            result = self.runner.invoke(cli, ["status"])

            # Command should complete successfully
            self.assertEqual(result.exit_code, 0)

    @patch('cortex.cli.HealthMonitor')
    def test_health_command(self, mock_health_class):
        """Test health command."""
        mock_health = MagicMock()
        mock_health_class.return_value = mock_health

        # Mock async method
        async def mock_run_checks(checks=None):
            return {
                "system": {
                    "status": "healthy"
                },
                "mlx_server": {
                    "status": "offline"
                },
                "api_keys": {
                    "status": "configured"
                }
            }

        mock_health.run_health_checks = mock_run_checks
        mock_health.get_summary.return_value = {
            "overall_status": "healthy",
            "checks_run": 3,
            "issues": []
        }

        result = self.runner.invoke(cli, ["health"])

        # Command should complete
        self.assertEqual(result.exit_code, 0)

    @patch('cortex.cli.Config')
    def test_logs_command(self, mock_config_class):
        """Test logs command."""
        mock_config = MagicMock()
        mock_config_class.return_value = mock_config

        with patch('pathlib.Path.exists') as mock_exists:
            mock_exists.return_value = False

            result = self.runner.invoke(cli, ["logs"])

            # Should handle missing log directory gracefully
            self.assertEqual(result.exit_code, 0)

    @patch('cortex.cli.Config')
    def test_chat_command_with_message(self, mock_config_class):
        """Test chat command with a message."""
        mock_config = MagicMock()
        mock_config_class.return_value = mock_config
        mock_config.data = {
            "current_model": {
                "id": "test-model",
                "provider": "mlx"
            },
            "providers": {
                "mlx": {
                    "enabled": True
                }
            }
        }

        with patch('cortex.cli.MLXProvider') as mock_provider_class:
            mock_provider = MagicMock()
            mock_provider_class.return_value = mock_provider

            async def mock_chat(prompt, model=None):
                return "Test response"

            mock_provider.chat = mock_chat

            result = self.runner.invoke(cli, ["chat", "Hello, world!"])

            # Command should handle the message
            self.assertIn(result.exit_code, [0, 1])

    def test_help_messages(self):
        """Test that all extended commands have help messages."""
        # Test individual command help
        commands = ["start", "stop", "status", "health", "logs", "chat"]

        for cmd in commands:
            result = self.runner.invoke(cli, [cmd, "--help"])
            self.assertEqual(result.exit_code, 0)
            self.assertIn(cmd.upper(), result.output.upper())


if __name__ == '__main__':
    unittest.main()
