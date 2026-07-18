"""
Tests for core.py module.
"""

import asyncio
import unittest
from unittest.mock import MagicMock, patch

from cortex.core import Cortex
from cortex.providers import ModelCapability, ProviderRegistry
from cortex.system_utils import SystemType

from tests.fakes import FakeProvider, make_model, make_system_info


class TestCortex(unittest.TestCase):
    """Test Cortex class."""

    def setUp(self):
        """Set up a Cortex instance with mocked config and a fake registry."""
        self.mock_config = MagicMock()
        self.mock_config.data = {"providers": {}, "current_model": {}}

        config_patcher = patch("cortex.core.Config", return_value=self.mock_config)
        detector_patcher = patch("cortex.core.SystemDetector")

        self.addCleanup(config_patcher.stop)
        self.addCleanup(detector_patcher.stop)

        config_patcher.start()
        mock_detector = detector_patcher.start()
        mock_detector.detect_system.return_value = make_system_info()

        self.cortex = Cortex()

        # Replace the global registry with an isolated one holding fake providers
        self.mlx_provider = FakeProvider(
            "mlx",
            [
                make_model("mlx-community/chat-model", "mlx"),
                make_model(
                    "mlx-community/code-model",
                    "mlx",
                    capabilities=[ModelCapability.CHAT, ModelCapability.CODE],
                    ram_gb=8.0,
                ),
            ],
        )
        self.ollama_provider = FakeProvider(
            "ollama", [make_model("llama3.2:latest", "ollama", ram_gb=3.0)]
        )
        registry = ProviderRegistry()
        registry.register(self.mlx_provider)
        registry.register(self.ollama_provider)
        self.cortex.registry = registry

    def test_initialization(self):
        """Test Cortex initialization."""
        self.assertIsNotNone(self.cortex.config)
        self.assertIsNotNone(self.cortex.system_info)
        self.assertEqual(self.cortex.system_info.os_type, SystemType.MACOS_APPLE_SILICON)
        self.assertIsNotNone(self.cortex.registry)

    def test_list_models_all_providers(self):
        """Test listing models from all providers."""
        result = asyncio.run(self.cortex.list_models())

        self.assertIn("models", result)
        self.assertIn("system_info", result)
        self.assertEqual(result["total_count"], 3)

        provider_names = {m.provider for m in result["models"]}
        self.assertIn("mlx", provider_names)
        self.assertIn("ollama", provider_names)

    def test_list_models_with_provider_filter(self):
        """Test listing models with provider filter."""
        result = asyncio.run(self.cortex.list_models(provider="ollama"))

        self.assertEqual(result["total_count"], 1)
        self.assertEqual(result["models"][0].provider, "ollama")

    def test_list_models_with_capability_filter(self):
        """Test listing models with capability filter."""
        result = asyncio.run(self.cortex.list_models(capability="code"))

        self.assertEqual(result["total_count"], 1)
        self.assertEqual(result["models"][0].id, "mlx-community/code-model")

    def test_list_models_with_max_ram_filter(self):
        """Test listing models with a maximum RAM budget."""
        result = asyncio.run(self.cortex.list_models(max_ram=4.0))

        self.assertEqual(result["total_count"], 2)
        for model in result["models"]:
            self.assertLessEqual(model.ram_gb, 4.0)

    @patch("cortex.core.ModelRecommender")
    def test_list_models_recommended(self, mock_recommender):
        """Test listing recommended models."""
        recommended = [make_model("mlx-community/chat-model", "mlx")]
        mock_recommender.recommend_models.return_value = recommended

        result = asyncio.run(self.cortex.list_models(recommended=True))

        mock_recommender.recommend_models.assert_called_once()
        self.assertEqual(result["total_count"], 1)
        self.assertEqual(result["models"][0].id, "mlx-community/chat-model")

    def test_set_model_success(self):
        """Test successful model selection."""
        result = asyncio.run(self.cortex.set_model("mlx-community/code-model"))

        self.assertTrue(result)
        self.mock_config.update_current_model.assert_called_once()
        model_info = self.mock_config.update_current_model.call_args[0][0]
        self.assertEqual(model_info["id"], "mlx-community/code-model")
        self.assertEqual(model_info["provider"], "mlx")

    def test_set_model_not_found(self):
        """Test model selection when model not found."""
        result = asyncio.run(self.cortex.set_model("non-existent-model"))

        self.assertFalse(result)
        self.mock_config.update_current_model.assert_not_called()

    def test_download_model_with_provider(self):
        """Test downloading a model through an explicit provider."""
        result = asyncio.run(self.cortex.download_model("mlx-community/chat-model", provider="mlx"))

        self.assertTrue(result)
        self.assertEqual(self.mlx_provider.download_calls, ["mlx-community/chat-model"])

    def test_download_model_finds_provider(self):
        """Test downloading resolves the provider by model availability."""
        result = asyncio.run(self.cortex.download_model("llama3.2:latest"))

        self.assertTrue(result)
        self.assertEqual(self.ollama_provider.download_calls, ["llama3.2:latest"])
        self.assertEqual(self.mlx_provider.download_calls, [])

    def test_download_model_not_found(self):
        """Test downloading fails when no provider has the model."""
        result = asyncio.run(self.cortex.download_model("unknown-model"))

        self.assertFalse(result)
        self.assertEqual(self.mlx_provider.download_calls, [])
        self.assertEqual(self.ollama_provider.download_calls, [])

    def test_start_server_with_explicit_model(self):
        """Test starting a server for an explicit model id."""
        result = asyncio.run(self.cortex.start_server("mlx-community/chat-model"))

        self.assertTrue(result)
        self.assertEqual(self.mlx_provider.started_models, ["mlx-community/chat-model"])

    def test_start_server_uses_current_model(self):
        """Test starting a server falls back to the configured model."""
        self.mock_config.data["current_model"] = {
            "id": "llama3.2:latest",
            "provider": "ollama",
        }

        result = asyncio.run(self.cortex.start_server())

        self.assertTrue(result)
        self.assertEqual(self.ollama_provider.started_models, ["llama3.2:latest"])

    def test_start_server_no_model(self):
        """Test starting a server with no model configured fails."""
        result = asyncio.run(self.cortex.start_server())

        self.assertFalse(result)

    def test_stop_server(self):
        """Test stopping a server for a specific provider."""
        result = asyncio.run(self.cortex.stop_server(provider="mlx"))

        self.assertTrue(result)
        self.assertEqual(self.mlx_provider.stop_calls, 1)

    def test_stop_server_no_provider(self):
        """Test stopping a server with no provider configured fails."""
        result = asyncio.run(self.cortex.stop_server())

        self.assertFalse(result)

    def test_get_status(self):
        """Test getting system status."""
        self.mock_config.data["current_model"] = {"id": "test-model", "provider": "mlx"}

        status = asyncio.run(self.cortex.get_status())

        self.assertIn("system", status)
        self.assertIn("current_model", status)
        self.assertIn("providers", status)
        self.assertEqual(status["current_model"]["id"], "test-model")
        self.assertEqual(status["system"].cpu_model, "Apple M1 Max")
        self.assertIn("mlx", status["providers"])
        self.assertIn("ollama", status["providers"])


if __name__ == "__main__":
    unittest.main()
