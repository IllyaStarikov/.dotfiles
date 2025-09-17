"""
Tests for core.py module.
"""

import json
from pathlib import Path
import tempfile
import unittest
from unittest.mock import call
from unittest.mock import MagicMock
from unittest.mock import patch

from cortex.core import Cortex
from cortex.providers import ModelCapability
from cortex.providers import ModelInfo
from cortex.system_utils import PerformanceTier
from cortex.system_utils import SystemInfo
from cortex.system_utils import SystemType


class TestCortex(unittest.TestCase):
    """Test Cortex class."""

    def setUp(self):
        """Set up test fixtures."""
        self.temp_dir = tempfile.mkdtemp()
        self.config_dir = Path(self.temp_dir) / "config"
        self.config_dir.mkdir(parents=True)

    @patch('cortex.core.Config')
    @patch('cortex.core.SystemDetector')
    def test_initialization(self, mock_detector, mock_config_class):
        """Test Cortex initialization."""
        mock_config = MagicMock()
        mock_config_class.return_value = mock_config

        mock_system_info = SystemInfo(os_type=SystemType.MACOS_APPLE_SILICON,
                                      cpu_model="Apple M1 Max",
                                      cpu_cores=10,
                                      ram_gb=64.0,
                                      ram_available_gb=30.0,
                                      gpu_info="Apple M1 Max",
                                      gpu_memory_gb=48.0,
                                      performance_tier=PerformanceTier.ULTRA,
                                      has_neural_engine=True,
                                      has_cuda=False,
                                      has_metal=True,
                                      platform_details={})
        mock_detector.detect.return_value = mock_system_info

        cortex = Cortex()

        self.assertIsNotNone(cortex.config)
        self.assertIsNotNone(cortex.system_info)
        self.assertEqual(cortex.system_info.os_type, SystemType.MACOS_APPLE_SILICON)
        self.assertIsNotNone(cortex.providers)
        self.assertIsNotNone(cortex.statistics)

    @patch('cortex.core.Config')
    @patch('cortex.core.SystemDetector')
    def test_list_models_all_providers(self, mock_detector, mock_config_class):
        """Test listing models from all providers."""
        mock_config = MagicMock()
        mock_config.data = {
            "providers": {
                "mlx": {
                    "enabled": True
                },
                "ollama": {
                    "enabled": True
                },
                "claude": {
                    "enabled": True
                },
                "openai": {
                    "enabled": True
                },
                "gemini": {
                    "enabled": True
                }
            }
        }
        mock_config_class.return_value = mock_config

        mock_system_info = MagicMock()
        mock_detector.detect.return_value = mock_system_info

        cortex = Cortex()

        # Mock provider responses
        for provider in cortex.providers.values():
            provider.list_models = MagicMock(return_value=[
                ModelInfo(id=f"{provider.name}-model",
                          name=f"{provider.name.upper()} Model",
                          provider=provider.name,
                          size_gb=1.0,
                          ram_gb=2.0,
                          context_window=4096,
                          capabilities=[ModelCapability.CHAT],
                          online=False,
                          open_source=True)
            ])

        models = cortex.list_models()

        # Should have models from all enabled providers
        self.assertGreater(len(models), 0)
        provider_names = {m["provider"] for m in models}
        self.assertIn("mlx", provider_names)

    @patch('cortex.core.Config')
    @patch('cortex.core.SystemDetector')
    def test_list_models_with_provider_filter(self, mock_detector, mock_config_class):
        """Test listing models with provider filter."""
        mock_config = MagicMock()
        mock_config.data = {"providers": {"mlx": {"enabled": True}, "ollama": {"enabled": True}}}
        mock_config_class.return_value = mock_config

        mock_system_info = MagicMock()
        mock_detector.detect.return_value = mock_system_info

        cortex = Cortex()

        # Mock provider responses
        cortex.providers["mlx"].list_models = MagicMock(return_value=[
            ModelInfo(id="mlx-model",
                      name="MLX Model",
                      provider="mlx",
                      size_gb=1.0,
                      ram_gb=2.0,
                      context_window=4096,
                      capabilities=[ModelCapability.CHAT],
                      online=False,
                      open_source=True)
        ])

        cortex.providers["ollama"].list_models = MagicMock(return_value=[
            ModelInfo(id="ollama-model",
                      name="Ollama Model",
                      provider="ollama",
                      size_gb=2.0,
                      ram_gb=3.0,
                      context_window=4096,
                      capabilities=[ModelCapability.CHAT],
                      online=False,
                      open_source=True)
        ])

        # Filter for MLX only
        models = cortex.list_models(provider="mlx")

        self.assertEqual(len(models), 1)
        self.assertEqual(models[0]["provider"], "mlx")

    @patch('cortex.core.Config')
    @patch('cortex.core.SystemDetector')
    def test_list_models_with_capability_filter(self, mock_detector, mock_config_class):
        """Test listing models with capability filter."""
        mock_config = MagicMock()
        mock_config.data = {"providers": {"mlx": {"enabled": True}}}
        mock_config_class.return_value = mock_config

        mock_system_info = MagicMock()
        mock_detector.detect.return_value = mock_system_info

        cortex = Cortex()

        # Mock models with different capabilities
        cortex.providers["mlx"].list_models = MagicMock(return_value=[
            ModelInfo(id="chat-model",
                      name="Chat Model",
                      provider="mlx",
                      size_gb=1.0,
                      ram_gb=2.0,
                      context_window=4096,
                      capabilities=[ModelCapability.CHAT],
                      online=False,
                      open_source=True),
            ModelInfo(id="code-model",
                      name="Code Model",
                      provider="mlx",
                      size_gb=2.0,
                      ram_gb=3.0,
                      context_window=8192,
                      capabilities=[ModelCapability.CHAT, ModelCapability.CODE],
                      online=False,
                      open_source=True)
        ])

        # Filter for code capability
        models = cortex.list_models(capability="code")

        self.assertEqual(len(models), 1)
        self.assertEqual(models[0]["id"], "code-model")

    @patch('cortex.core.ModelRecommender')
    @patch('cortex.core.Config')
    @patch('cortex.core.SystemDetector')
    def test_list_models_recommended(self, mock_detector, mock_config_class, mock_recommender):
        """Test listing recommended models."""
        mock_config = MagicMock()
        mock_config.data = {"providers": {"mlx": {"enabled": True}}}
        mock_config_class.return_value = mock_config

        mock_system_info = MagicMock()
        mock_detector.detect.return_value = mock_system_info

        cortex = Cortex()

        test_models = [
            ModelInfo(id="recommended-model",
                      name="Recommended Model",
                      provider="mlx",
                      size_gb=1.0,
                      ram_gb=2.0,
                      context_window=4096,
                      capabilities=[ModelCapability.CHAT],
                      online=False,
                      open_source=True)
        ]

        cortex.providers["mlx"].list_models = MagicMock(return_value=test_models)
        mock_recommender.recommend_models.return_value = test_models

        models = cortex.list_models(recommended=True)

        mock_recommender.recommend_models.assert_called_once()
        self.assertEqual(len(models), 1)
        self.assertEqual(models[0]["id"], "recommended-model")

    @patch('cortex.core.Config')
    @patch('cortex.core.SystemDetector')
    def test_switch_model_success(self, mock_detector, mock_config_class):
        """Test successful model switching."""
        mock_config = MagicMock()
        mock_config.data = {"providers": {"openai": {"enabled": True}}}
        mock_config_class.return_value = mock_config

        mock_system_info = MagicMock()
        mock_detector.detect.return_value = mock_system_info

        cortex = Cortex()

        # Mock finding the model
        test_model = ModelInfo(id="gpt-4",
                               name="GPT-4",
                               provider="openai",
                               size_gb=0,
                               ram_gb=0,
                               context_window=8192,
                               capabilities=[ModelCapability.CHAT],
                               online=True,
                               open_source=False)

        cortex.providers["openai"].list_models = MagicMock(return_value=[test_model])

        result = cortex.switch_model("gpt-4")

        self.assertTrue(result)
        mock_config.update_current_model.assert_called_once()

    @patch('cortex.core.Config')
    @patch('cortex.core.SystemDetector')
    def test_switch_model_not_found(self, mock_detector, mock_config_class):
        """Test model switching when model not found."""
        mock_config = MagicMock()
        mock_config.data = {"providers": {"openai": {"enabled": True}}}
        mock_config_class.return_value = mock_config

        mock_system_info = MagicMock()
        mock_detector.detect.return_value = mock_system_info

        cortex = Cortex()

        cortex.providers["openai"].list_models = MagicMock(return_value=[])

        result = cortex.switch_model("non-existent-model")

        self.assertFalse(result)
        mock_config.update_current_model.assert_not_called()

    @patch('cortex.core.Config')
    @patch('cortex.core.SystemDetector')
    def test_get_current_model(self, mock_detector, mock_config_class):
        """Test getting current model."""
        mock_config = MagicMock()
        mock_config.data = {
            "current_model": {
                "id": "current-model",
                "name": "Current Model",
                "provider": "mlx"
            },
            "providers": {}
        }
        mock_config_class.return_value = mock_config

        mock_system_info = MagicMock()
        mock_detector.detect.return_value = mock_system_info

        cortex = Cortex()

        current = cortex.get_current_model()

        self.assertIsNotNone(current)
        self.assertEqual(current["id"], "current-model")

    @patch('cortex.core.Config')
    @patch('cortex.core.SystemDetector')
    def test_download_model_mlx(self, mock_detector, mock_config_class):
        """Test downloading MLX model."""
        mock_config = MagicMock()
        mock_config.data = {"providers": {"mlx": {"enabled": True}}}
        mock_config_class.return_value = mock_config

        mock_system_info = MagicMock()
        mock_detector.detect.return_value = mock_system_info

        cortex = Cortex()

        # Mock MLX provider download
        cortex.providers["mlx"].download_model = MagicMock(return_value=True)

        result = cortex.download_model("mlx-community/test-model")

        self.assertTrue(result)
        cortex.providers["mlx"].download_model.assert_called_once_with("mlx-community/test-model",
                                                                       force=False)

    @patch('cortex.core.Config')
    @patch('cortex.core.SystemDetector')
    def test_download_model_ollama(self, mock_detector, mock_config_class):
        """Test downloading Ollama model."""
        mock_config = MagicMock()
        mock_config.data = {"providers": {"ollama": {"enabled": True}}}
        mock_config_class.return_value = mock_config

        mock_system_info = MagicMock()
        mock_detector.detect.return_value = mock_system_info

        cortex = Cortex()

        # Mock Ollama provider download
        cortex.providers["ollama"].download_model = MagicMock(return_value=True)

        result = cortex.download_model("llama2")

        self.assertTrue(result)
        cortex.providers["ollama"].download_model.assert_called_once()

    @patch('cortex.core.Config')
    @patch('cortex.core.SystemDetector')
    def test_chat_with_current_model(self, mock_detector, mock_config_class):
        """Test chat with current model."""
        mock_config = MagicMock()
        mock_config.data = {
            "current_model": {
                "id": "gpt-4",
                "provider": "openai"
            },
            "providers": {
                "openai": {
                    "enabled": True
                }
            }
        }
        mock_config_class.return_value = mock_config

        mock_system_info = MagicMock()
        mock_detector.detect.return_value = mock_system_info

        cortex = Cortex()

        # Mock provider chat
        cortex.providers["openai"].chat = MagicMock(return_value="Test response")

        response = cortex.chat("Test prompt")

        self.assertEqual(response, "Test response")
        cortex.providers["openai"].chat.assert_called_once_with("Test prompt", model="gpt-4")

    @patch('cortex.core.Config')
    @patch('cortex.core.SystemDetector')
    def test_chat_with_specified_model(self, mock_detector, mock_config_class):
        """Test chat with specified model."""
        mock_config = MagicMock()
        mock_config.data = {"providers": {"claude": {"enabled": True}}}
        mock_config_class.return_value = mock_config

        mock_system_info = MagicMock()
        mock_detector.detect.return_value = mock_system_info

        cortex = Cortex()

        # Mock finding and using the model
        cortex.providers["claude"].chat = MagicMock(return_value="Claude response")

        response = cortex.chat("Test prompt", model="claude-3-opus")

        self.assertEqual(response, "Claude response")

    @patch('cortex.core.Config')
    @patch('cortex.core.SystemDetector')
    def test_get_logs(self, mock_detector, mock_config_class):
        """Test getting logs."""
        mock_config = MagicMock()
        mock_config.data = {"providers": {}}
        mock_config_class.return_value = mock_config

        mock_system_info = MagicMock()
        mock_detector.detect.return_value = mock_system_info

        cortex = Cortex()

        # Mock statistics logs
        cortex.statistics.get_recent_sessions = MagicMock(return_value=[{
            "session_id": "test-session",
            "model": "gpt-4",
            "timestamp": "2024-01-01T12:00:00"
        }])

        logs = cortex.get_logs(lines=5)

        self.assertIsInstance(logs, list)
        cortex.statistics.get_recent_sessions.assert_called_once_with(5)

    @patch('cortex.core.Config')
    @patch('cortex.core.SystemDetector')
    def test_get_status(self, mock_detector, mock_config_class):
        """Test getting status."""
        mock_config = MagicMock()
        mock_config.data = {
            "current_model": {
                "id": "test-model",
                "provider": "mlx"
            },
            "providers": {}
        }
        mock_config_class.return_value = mock_config

        mock_system_info = SystemInfo(os_type=SystemType.MACOS_APPLE_SILICON,
                                      cpu_model="Apple M1 Max",
                                      cpu_cores=10,
                                      ram_gb=64.0,
                                      ram_available_gb=30.0,
                                      gpu_info="Apple M1 Max",
                                      gpu_memory_gb=48.0,
                                      performance_tier=PerformanceTier.ULTRA,
                                      has_neural_engine=True,
                                      has_cuda=False,
                                      has_metal=True,
                                      platform_details={})
        mock_detector.detect.return_value = mock_system_info

        cortex = Cortex()

        # Mock server status checks
        with patch('subprocess.run') as mock_run:
            mock_run.return_value = MagicMock(returncode=0)

            status = cortex.get_status()

            self.assertIn("system", status)
            self.assertIn("current_model", status)
            self.assertIn("servers", status)
            self.assertEqual(status["system"]["cpu_model"], "Apple M1 Max")
            self.assertEqual(status["system"]["ram_gb"], 64.0)


if __name__ == '__main__':
    unittest.main()
