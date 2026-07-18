"""
Tests for cli.py module.
"""

import glob
import json
import unittest
from unittest.mock import AsyncMock, MagicMock, patch

from click.testing import CliRunner
from cortex.cli import cli
from cortex.providers import ModelCapability, ProviderRegistry

from tests.fakes import FakeProvider, make_model, make_system_info


class CLITestBase(unittest.TestCase):
    """Shared fixture: patched config, fake registry, fake system detection."""

    def setUp(self):
        """Set up test fixtures."""
        self.runner = CliRunner()

        self.mock_config = MagicMock()
        self.mock_config.data = {
            "providers": {
                "mlx": {"enabled": True, "port": 8080},
                "ollama": {"enabled": True, "port": 11434},
            },
            "current_model": {},
        }

        config_patcher = patch("cortex.cli.Config", return_value=self.mock_config)
        config_patcher.start()
        self.addCleanup(config_patcher.stop)

        # Registry backed by offline fake providers
        self.mlx_provider = FakeProvider(
            "mlx",
            [
                make_model("mlx-chat", "mlx"),
                make_model(
                    "mlx-coder",
                    "mlx",
                    capabilities=[ModelCapability.CHAT, ModelCapability.CODE],
                    ram_gb=8.0,
                ),
            ],
        )
        self.ollama_provider = FakeProvider(
            "ollama", [make_model("tiny-llama:latest", "ollama", ram_gb=3.0)]
        )
        self.registry = ProviderRegistry()
        self.registry.register(self.mlx_provider)
        self.registry.register(self.ollama_provider)
        # The CLI group callback initializes providers; keep it a no-op here so no
        # real provider classes (and their network clients) are ever constructed.
        self.registry.initialize_providers = AsyncMock()

        registry_patcher = patch("cortex.cli.registry", self.registry)
        registry_patcher.start()
        self.addCleanup(registry_patcher.stop)

        # System detection must not shell out during tests
        detector_patcher = patch(
            "cortex.system_utils.SystemDetector.detect_system", return_value=make_system_info()
        )
        detector_patcher.start()
        self.addCleanup(detector_patcher.stop)


class TestCLIGroup(CLITestBase):
    """Test the top-level CLI group."""

    def test_cli_help(self):
        """Test main CLI group help output."""
        result = self.runner.invoke(cli, ["--help"])

        self.assertEqual(result.exit_code, 0)
        self.assertIn("Cortex - Unified AI Model Management", result.output)

    def test_cli_version(self):
        """Test CLI version display."""
        result = self.runner.invoke(cli, ["--version"])

        # Version option is not implemented; click exits 2 for the unknown
        # option. Accept 0 in case it gets added later.
        self.assertIn(str(result.exit_code), ["0", "2"])


class TestListCommand(CLITestBase):
    """Test the list command."""

    def test_list_default(self):
        """Test list command with default parameters."""
        result = self.runner.invoke(cli, ["list"])

        self.assertEqual(result.exit_code, 0)
        self.assertIn("mlx-chat", result.output)
        self.assertIn("mlx-coder", result.output)
        self.assertIn("tiny-llama:latest", result.output)
        # Providers are rendered as grouped section headers
        self.assertIn("MLX", result.output)
        self.assertIn("OLLAMA", result.output)

    def test_list_provider_filter(self):
        """Test list command with provider filter."""
        result = self.runner.invoke(cli, ["list", "--provider", "ollama"])

        self.assertEqual(result.exit_code, 0)
        self.assertIn("tiny-llama:latest", result.output)
        self.assertNotIn("mlx-chat", result.output)
        self.assertNotIn("mlx-coder", result.output)

    def test_list_capability_filter(self):
        """Test list command with capability filter."""
        result = self.runner.invoke(cli, ["list", "--capability", "code"])

        self.assertEqual(result.exit_code, 0)
        self.assertIn("mlx-coder", result.output)
        self.assertNotIn("mlx-chat", result.output)
        self.assertNotIn("tiny-llama:latest", result.output)

    def test_list_max_ram_filter(self):
        """Test list command with a RAM budget filter."""
        result = self.runner.invoke(cli, ["list", "--max-ram", "4.0"])

        self.assertEqual(result.exit_code, 0)
        self.assertIn("mlx-chat", result.output)  # 2.0 GB
        self.assertIn("tiny-llama:latest", result.output)  # 3.0 GB
        self.assertNotIn("mlx-coder", result.output)  # 8.0 GB

    def test_list_summary(self):
        """Test list command summary mode."""
        result = self.runner.invoke(cli, ["list", "--summary"])

        self.assertEqual(result.exit_code, 0)
        self.assertIn("AI Models by Provider", result.output)
        self.assertIn("TOTAL", result.output)

    def test_list_detailed(self):
        """Test list command detailed mode."""
        result = self.runner.invoke(cli, ["list", "--detailed"])

        self.assertEqual(result.exit_code, 0)
        self.assertIn("mlx-chat", result.output)
        self.assertIn("Open Source", result.output)

    def test_list_export_json(self):
        """Test list command JSON export writes a parseable file."""
        with self.runner.isolated_filesystem():
            result = self.runner.invoke(cli, ["list", "--export", "json"])

            self.assertEqual(result.exit_code, 0)
            exported = glob.glob("cortex_models_*.json")
            self.assertEqual(len(exported), 1)

            with open(exported[0]) as f:
                data = json.load(f)

            self.assertEqual(len(data), 3)
            ids = {entry["id"] for entry in data}
            self.assertIn("mlx-chat", ids)
            self.assertIn("tiny-llama:latest", ids)


class TestModelCommand(CLITestBase):
    """Test the model command."""

    def test_model_show_no_current(self):
        """Test model command when no model is configured."""
        result = self.runner.invoke(cli, ["model"])

        self.assertEqual(result.exit_code, 0)
        self.assertIn("No model currently configured", result.output)

    def test_model_show_current(self):
        """Test model command showing the current model."""
        self.mock_config.data["current_model"] = {
            "id": "tiny-llama:latest",
            "name": "Tiny Llama",
            "provider": "ollama",
        }

        result = self.runner.invoke(cli, ["model"])

        self.assertEqual(result.exit_code, 0)
        self.assertIn("Current Model Configuration", result.output)
        self.assertIn("tiny-llama:latest", result.output)
        self.assertIn("ollama", result.output)

    def test_model_env_output(self):
        """Test model --env emits shell export lines."""
        self.mock_config.data["current_model"] = {"id": "mlx-chat", "provider": "mlx"}

        result = self.runner.invoke(cli, ["model", "--env"])

        self.assertEqual(result.exit_code, 0)
        self.assertIn('export CORTEX_PROVIDER="mlx"', result.output)
        self.assertIn('export CORTEX_MODEL="mlx-chat"', result.output)
        self.assertIn('export CORTEX_ENDPOINT="http://localhost:8080/v1"', result.output)
        self.assertIn('export AVANTE_PROVIDER="openai"', result.output)

    def test_model_set_infers_provider(self):
        """Test setting a model infers the provider from the id."""
        result = self.runner.invoke(cli, ["model", "mlx-community/new-model"])

        self.assertEqual(result.exit_code, 0)
        self.assertIn("Model set to", result.output)
        self.mock_config.update_current_model.assert_called_once()
        model_info = self.mock_config.update_current_model.call_args[0][0]
        self.assertEqual(model_info["id"], "mlx-community/new-model")
        self.assertEqual(model_info["provider"], "mlx")

    def test_model_set_unknown_provider_warns(self):
        """Test setting a model with an unrecognizable id warns and aborts."""
        result = self.runner.invoke(cli, ["model", "somemodel"])

        self.assertEqual(result.exit_code, 0)
        self.assertIn("Could not infer provider", result.output)
        self.mock_config.update_current_model.assert_not_called()

    def test_model_set_with_validation_found(self):
        """Test setting a model with --validate when the model exists."""
        result = self.runner.invoke(cli, ["model", "mlx-chat", "--validate"])

        self.assertEqual(result.exit_code, 0)
        self.assertIn("Model set to", result.output)
        self.mock_config.update_current_model.assert_called_once()
        model_info = self.mock_config.update_current_model.call_args[0][0]
        self.assertEqual(model_info["id"], "mlx-chat")
        self.assertEqual(model_info["provider"], "mlx")
        self.assertIn("chat", model_info["capabilities"])

    def test_model_set_with_validation_not_found(self):
        """Test setting a model with --validate when the model is missing."""
        result = self.runner.invoke(cli, ["model", "no-such-model", "--validate"])

        self.assertEqual(result.exit_code, 0)
        self.assertIn("not found", result.output)
        self.mock_config.update_current_model.assert_not_called()


class TestDownloadCommand(CLITestBase):
    """Test the download command."""

    def test_download_no_model_configured(self):
        """Test download with neither --model nor a configured model."""
        result = self.runner.invoke(cli, ["download"])

        self.assertEqual(result.exit_code, 0)
        self.assertIn("No model configured", result.output)

    def test_download_cloud_provider_skipped(self):
        """Test download is skipped for cloud providers."""
        self.mock_config.data["current_model"] = {"id": "claude-3-opus", "provider": "claude"}

        result = self.runner.invoke(cli, ["download"])

        self.assertEqual(result.exit_code, 0)
        self.assertIn("doesn't require downloading", result.output)

    def test_download_success(self):
        """Test downloading a model that is not yet available."""
        result = self.runner.invoke(cli, ["download", "--model", "new-model:latest"])

        self.assertEqual(result.exit_code, 0)
        self.assertIn("Successfully downloaded", result.output)
        self.assertEqual(self.ollama_provider.download_calls, ["new-model:latest"])
        # Download statistics are recorded and persisted
        self.assertEqual(len(self.mock_config.data["download_stats"]), 1)
        self.assertTrue(self.mock_config.data["download_stats"][0]["success"])
        self.mock_config.save.assert_called()

    def test_download_force_skips_availability_check(self):
        """Test --force downloads even when the model is already available."""
        result = self.runner.invoke(cli, ["download", "--model", "tiny-llama:latest", "--force"])

        self.assertEqual(result.exit_code, 0)
        self.assertIn("Successfully downloaded", result.output)
        self.assertEqual(self.ollama_provider.download_calls, ["tiny-llama:latest"])

    def test_download_failure(self):
        """Test download failure is reported."""
        self.ollama_provider.download_result = False

        result = self.runner.invoke(cli, ["download", "--model", "new-model:latest"])

        self.assertEqual(result.exit_code, 0)
        self.assertIn("Failed to download", result.output)
        self.assertEqual(len(self.mock_config.data["download_stats"]), 1)
        self.assertFalse(self.mock_config.data["download_stats"][0]["success"])

    def test_download_no_progress(self):
        """Test download with the progress bar disabled."""
        result = self.runner.invoke(
            cli, ["download", "--model", "new-model:latest", "--no-progress"]
        )

        self.assertEqual(result.exit_code, 0)
        self.assertIn("Successfully downloaded", result.output)


if __name__ == "__main__":
    unittest.main()
