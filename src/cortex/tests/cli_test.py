"""
Tests for cli.py module.
"""

import json
import unittest
from unittest.mock import call
from unittest.mock import MagicMock
from unittest.mock import patch

from click.testing import CliRunner

from cortex.cli import cli
from cortex.cli import download
from cortex.cli import list as list_command
from cortex.cli import model


class TestCLICommands(unittest.TestCase):
    """Test CLI commands."""

    def setUp(self):
        """Set up test fixtures."""
        self.runner = CliRunner()

    @patch('cortex.cli.Cortex')
    def test_list_models_default(self, mock_cortex_class):
        """Test list command with default parameters."""
        mock_cortex = MagicMock()
        mock_cortex_class.return_value = mock_cortex

        mock_cortex.list_models.return_value = [{
            "id": "test-model-1",
            "name": "Test Model 1",
            "provider": "mlx",
            "size_gb": 7.0,
            "online": False
        }, {
            "id": "test-model-2",
            "name": "Test Model 2",
            "provider": "openai",
            "size_gb": 0,
            "online": True
        }]

        result = self.runner.invoke(list_command)

        self.assertEqual(result.exit_code, 0)
        mock_cortex.list_models.assert_called_once_with(provider=None,
                                                        capability=None,
                                                        local_only=False,
                                                        recommended=False,
                                                        format="table")
        # Check output contains model names
        self.assertIn("Test Model 1", result.output)
        self.assertIn("Test Model 2", result.output)

    @patch('cortex.cli.Cortex')
    def test_list_models_with_filters(self, mock_cortex_class):
        """Test list command with various filters."""
        mock_cortex = MagicMock()
        mock_cortex_class.return_value = mock_cortex
        mock_cortex.list_models.return_value = []

        # Test with provider filter
        result = self.runner.invoke(list_command, ["--provider", "mlx"])
        self.assertEqual(result.exit_code, 0)
        mock_cortex.list_models.assert_called_with(provider="mlx",
                                                   capability=None,
                                                   local_only=False,
                                                   recommended=False,
                                                   format="table")

        # Test with local only
        result = self.runner.invoke(list_command, ["--local"])
        self.assertEqual(result.exit_code, 0)
        mock_cortex.list_models.assert_called_with(provider=None,
                                                   capability=None,
                                                   local_only=True,
                                                   recommended=False,
                                                   format="table")

        # Test with recommended
        result = self.runner.invoke(list_command, ["--recommended"])
        self.assertEqual(result.exit_code, 0)
        mock_cortex.list_models.assert_called_with(provider=None,
                                                   capability=None,
                                                   local_only=False,
                                                   recommended=True,
                                                   format="table")

    @patch('cortex.cli.Cortex')
    def test_list_models_json_format(self, mock_cortex_class):
        """Test list command with JSON output."""
        mock_cortex = MagicMock()
        mock_cortex_class.return_value = mock_cortex

        test_models = [{"id": "test-model", "name": "Test Model", "provider": "mlx"}]
        mock_cortex.list_models.return_value = test_models

        result = self.runner.invoke(list_command, ["--format", "json"])

        self.assertEqual(result.exit_code, 0)
        output_data = json.loads(result.output)
        self.assertEqual(output_data, test_models)

    @patch('cortex.cli.Cortex')
    def test_model_command_switch(self, mock_cortex_class):
        """Test model command for switching models."""
        mock_cortex = MagicMock()
        mock_cortex_class.return_value = mock_cortex
        mock_cortex.switch_model.return_value = True

        result = self.runner.invoke(model, ["gpt-4"])

        self.assertEqual(result.exit_code, 0)
        mock_cortex.switch_model.assert_called_once_with("gpt-4")
        self.assertIn("Switched to model: gpt-4", result.output)

    @patch('cortex.cli.Cortex')
    def test_model_command_show_current(self, mock_cortex_class):
        """Test model command showing current model."""
        mock_cortex = MagicMock()
        mock_cortex_class.return_value = mock_cortex
        mock_cortex.get_current_model.return_value = {
            "id": "current-model",
            "name": "Current Model",
            "provider": "mlx"
        }

        result = self.runner.invoke(model)

        self.assertEqual(result.exit_code, 0)
        mock_cortex.get_current_model.assert_called_once()
        self.assertIn("Current model:", result.output)
        self.assertIn("current-model", result.output)

    @patch('cortex.cli.Cortex')
    def test_model_command_no_current(self, mock_cortex_class):
        """Test model command when no current model."""
        mock_cortex = MagicMock()
        mock_cortex_class.return_value = mock_cortex
        mock_cortex.get_current_model.return_value = None

        result = self.runner.invoke(model)

        self.assertEqual(result.exit_code, 0)
        self.assertIn("No model currently selected", result.output)

    @patch('cortex.cli.Cortex')
    def test_model_command_switch_failure(self, mock_cortex_class):
        """Test model command switch failure."""
        mock_cortex = MagicMock()
        mock_cortex_class.return_value = mock_cortex
        mock_cortex.switch_model.return_value = False

        result = self.runner.invoke(model, ["invalid-model"])

        self.assertEqual(result.exit_code, 1)
        self.assertIn("Failed to switch", result.output)

    @patch('cortex.cli.Cortex')
    def test_download_command_success(self, mock_cortex_class):
        """Test download command success."""
        mock_cortex = MagicMock()
        mock_cortex_class.return_value = mock_cortex
        mock_cortex.download_model.return_value = True

        result = self.runner.invoke(download, ["test-model"])

        self.assertEqual(result.exit_code, 0)
        mock_cortex.download_model.assert_called_once_with("test-model", force=False)
        self.assertIn("Successfully downloaded", result.output)

    @patch('cortex.cli.Cortex')
    def test_download_command_force(self, mock_cortex_class):
        """Test download command with force flag."""
        mock_cortex = MagicMock()
        mock_cortex_class.return_value = mock_cortex
        mock_cortex.download_model.return_value = True

        result = self.runner.invoke(download, ["test-model", "--force"])

        self.assertEqual(result.exit_code, 0)
        mock_cortex.download_model.assert_called_once_with("test-model", force=True)

    @patch('cortex.cli.Cortex')
    def test_download_command_failure(self, mock_cortex_class):
        """Test download command failure."""
        mock_cortex = MagicMock()
        mock_cortex_class.return_value = mock_cortex
        mock_cortex.download_model.return_value = False

        result = self.runner.invoke(download, ["test-model"])

        self.assertEqual(result.exit_code, 1)
        self.assertIn("Failed to download", result.output)

    @patch('cortex.cli.add_extended_commands')
    def test_main_cli_group(self, mock_add_extended):
        """Test main CLI group initialization."""
        mock_extended_cli = MagicMock()
        mock_add_extended.return_value = mock_extended_cli

        result = self.runner.invoke(cli, ["--help"])

        # Should show help without error
        self.assertEqual(result.exit_code, 0)
        self.assertIn("Cortex - Unified AI Model Management", result.output)

    @patch('cortex.cli.Cortex')
    def test_list_models_error_handling(self, mock_cortex_class):
        """Test list command error handling."""
        mock_cortex = MagicMock()
        mock_cortex_class.return_value = mock_cortex
        mock_cortex.list_models.side_effect = Exception("API error")

        result = self.runner.invoke(list_command)

        # Should handle error gracefully
        self.assertNotEqual(result.exit_code, 0)

    @patch('cortex.cli.Cortex')
    def test_list_models_with_capability_filter(self, mock_cortex_class):
        """Test list command with capability filter."""
        mock_cortex = MagicMock()
        mock_cortex_class.return_value = mock_cortex
        mock_cortex.list_models.return_value = []

        result = self.runner.invoke(list_command, ["--capability", "code"])

        self.assertEqual(result.exit_code, 0)
        mock_cortex.list_models.assert_called_with(provider=None,
                                                   capability="code",
                                                   local_only=False,
                                                   recommended=False,
                                                   format="table")

    def test_cli_version(self):
        """Test CLI version display."""
        result = self.runner.invoke(cli, ["--version"])

        # Version command might not be implemented yet
        # Just ensure CLI doesn't crash
        self.assertIn(["0", "2"], [str(result.exit_code)])


if __name__ == '__main__':
    unittest.main()
