"""
Tests for mlx.py provider module.
"""

import json
import unittest
from unittest.mock import AsyncMock
from unittest.mock import MagicMock
from unittest.mock import patch

import aiohttp

from cortex.providers import ModelCapability
from cortex.providers import ModelInfo
from cortex.providers.mlx import MLXProvider


class TestMLXProvider(unittest.TestCase):
    """Test MLX Provider."""

    def setUp(self):
        """Set up test fixtures."""
        self.provider = MLXProvider()

    def test_initialization(self):
        """Test MLX provider initialization."""
        self.assertEqual(self.provider.name, "mlx")
        self.assertEqual(self.provider.base_url, "http://localhost:8080")
        self.assertTrue(self.provider.supports_download)
        self.assertFalse(self.provider.requires_api_key)

    @patch('aiohttp.ClientSession')
    def test_list_models_success(self, mock_session_class):
        """Test listing MLX models successfully."""
        mock_session = AsyncMock()
        mock_response = AsyncMock()
        mock_response.status = 200
        mock_response.json = AsyncMock(
            return_value={
                "data": [{
                    "id": "mlx-community/test-model-7b",
                    "object": "model"
                }, {
                    "id": "mlx-community/code-model-13b",
                    "object": "model"
                }]
            })

        mock_session.get.return_value.__aenter__.return_value = mock_response
        mock_session_class.return_value.__aenter__.return_value = mock_session

        models = self.provider.list_models()

        self.assertEqual(len(models), 2)
        self.assertIsInstance(models[0], ModelInfo)
        self.assertEqual(models[0].id, "mlx-community/test-model-7b")
        self.assertEqual(models[0].provider, "mlx")

    @patch('aiohttp.ClientSession')
    def test_list_models_server_offline(self, mock_session_class):
        """Test listing models when MLX server is offline."""
        mock_session = AsyncMock()
        mock_session.get.side_effect = aiohttp.ClientConnectionError("Connection refused")
        mock_session_class.return_value.__aenter__.return_value = mock_session

        models = self.provider.list_models()

        self.assertEqual(models, [])

    @patch('aiohttp.ClientSession')
    def test_list_models_parse_size(self, mock_session_class):
        """Test model size parsing from model ID."""
        mock_session = AsyncMock()
        mock_response = AsyncMock()
        mock_response.status = 200
        mock_response.json = AsyncMock(
            return_value={
                "data": [{
                    "id": "mlx-community/model-1b",
                    "object": "model"
                }, {
                    "id": "mlx-community/model-7b-4bit",
                    "object": "model"
                }, {
                    "id": "mlx-community/model-13b",
                    "object": "model"
                }, {
                    "id": "mlx-community/model-70b",
                    "object": "model"
                }]
            })

        mock_session.get.return_value.__aenter__.return_value = mock_response
        mock_session_class.return_value.__aenter__.return_value = mock_session

        models = self.provider.list_models()

        # Check size parsing
        self.assertAlmostEqual(models[0].size_gb, 0.5, places=1)  # 1B model
        self.assertAlmostEqual(models[1].size_gb, 3.5, places=1)  # 7B 4bit model
        self.assertAlmostEqual(models[2].size_gb, 13.0, places=1)  # 13B model
        self.assertAlmostEqual(models[3].size_gb, 70.0, places=1)  # 70B model

        # Check RAM requirements
        self.assertAlmostEqual(models[0].ram_gb, 1.0, places=1)
        self.assertAlmostEqual(models[1].ram_gb, 4.0, places=1)
        self.assertAlmostEqual(models[2].ram_gb, 14.0, places=1)
        self.assertAlmostEqual(models[3].ram_gb, 75.0, places=1)

    @patch('aiohttp.ClientSession')
    def test_list_models_detect_capabilities(self, mock_session_class):
        """Test capability detection from model names."""
        mock_session = AsyncMock()
        mock_response = AsyncMock()
        mock_response.status = 200
        mock_response.json = AsyncMock(
            return_value={
                "data": [{
                    "id": "mlx-community/CodeLlama-7b",
                    "object": "model"
                }, {
                    "id": "mlx-community/Llama-3-8b",
                    "object": "model"
                }, {
                    "id": "mlx-community/phi-3-vision",
                    "object": "model"
                }]
            })

        mock_session.get.return_value.__aenter__.return_value = mock_response
        mock_session_class.return_value.__aenter__.return_value = mock_session

        models = self.provider.list_models()

        # CodeLlama should have CODE capability
        self.assertIn(ModelCapability.CODE, models[0].capabilities)

        # Vision model should have VISION capability
        self.assertIn(ModelCapability.VISION, models[2].capabilities)

        # All should have CHAT capability
        for model in models:
            self.assertIn(ModelCapability.CHAT, model.capabilities)

    @patch('subprocess.run')
    def test_download_model_success(self, mock_run):
        """Test downloading MLX model successfully."""
        mock_run.return_value = MagicMock(returncode=0)

        result = self.provider.download_model("mlx-community/test-model")

        self.assertTrue(result)
        mock_run.assert_called_once()
        call_args = mock_run.call_args[0][0]
        self.assertIn("mlx_lm.convert", call_args)
        self.assertIn("--hf-path", call_args)
        self.assertIn("mlx-community/test-model", call_args)

    @patch('subprocess.run')
    def test_download_model_with_force(self, mock_run):
        """Test downloading MLX model with force flag."""
        mock_run.return_value = MagicMock(returncode=0)

        result = self.provider.download_model("mlx-community/test-model", force=True)

        self.assertTrue(result)
        # Force flag doesn't change MLX convert command
        mock_run.assert_called_once()

    @patch('subprocess.run')
    def test_download_model_failure(self, mock_run):
        """Test MLX model download failure."""
        mock_run.return_value = MagicMock(returncode=1, stderr="Error downloading")

        result = self.provider.download_model("mlx-community/test-model")

        self.assertFalse(result)

    @patch('aiohttp.ClientSession')
    def test_chat_success(self, mock_session_class):
        """Test chat with MLX model."""
        mock_session = AsyncMock()
        mock_response = AsyncMock()
        mock_response.status = 200
        mock_response.json = AsyncMock(
            return_value={
                "choices": [{
                    "message": {
                        "content": "Test response from MLX"
                    }
                }],
                "usage": {
                    "prompt_tokens": 10,
                    "completion_tokens": 20,
                    "total_tokens": 30
                }
            })

        mock_session.post.return_value.__aenter__.return_value = mock_response
        mock_session_class.return_value.__aenter__.return_value = mock_session

        response = self.provider.chat("Test prompt", model="mlx-community/test-model")

        self.assertEqual(response, "Test response from MLX")

        # Check request was made correctly
        mock_session.post.assert_called_once()
        call_args = mock_session.post.call_args
        self.assertEqual(call_args[0][0], "http://localhost:8080/v1/chat/completions")

        # Check request body
        request_data = call_args[1]["json"]
        self.assertEqual(request_data["model"], "mlx-community/test-model")
        self.assertEqual(request_data["messages"][0]["role"], "user")
        self.assertEqual(request_data["messages"][0]["content"], "Test prompt")

    @patch('aiohttp.ClientSession')
    def test_chat_server_offline(self, mock_session_class):
        """Test chat when MLX server is offline."""
        mock_session = AsyncMock()
        mock_session.post.side_effect = aiohttp.ClientConnectionError("Connection refused")
        mock_session_class.return_value.__aenter__.return_value = mock_session

        response = self.provider.chat("Test prompt", model="mlx-community/test-model")

        self.assertEqual(response, "Error: MLX server is not running")

    @patch('aiohttp.ClientSession')
    def test_chat_error_response(self, mock_session_class):
        """Test chat with error response from server."""
        mock_session = AsyncMock()
        mock_response = AsyncMock()
        mock_response.status = 500
        mock_response.text = AsyncMock(return_value="Internal server error")

        mock_session.post.return_value.__aenter__.return_value = mock_response
        mock_session_class.return_value.__aenter__.return_value = mock_session

        response = self.provider.chat("Test prompt", model="mlx-community/test-model")

        self.assertIn("Error", response)

    def test_parse_model_info(self):
        """Test parsing model information from ID."""
        # Test standard model
        info = self.provider._parse_model_info("mlx-community/Llama-3-8b-Instruct-4bit")

        self.assertEqual(info.name, "Llama 3 8B Instruct (4-bit)")
        self.assertAlmostEqual(info.size_gb, 4.0, places=1)
        self.assertAlmostEqual(info.ram_gb, 5.0, places=1)
        self.assertEqual(info.context_window, 8192)
        self.assertIn(ModelCapability.CHAT, info.capabilities)

        # Test code model
        info = self.provider._parse_model_info("mlx-community/CodeLlama-13b")

        self.assertIn(ModelCapability.CODE, info.capabilities)
        self.assertAlmostEqual(info.size_gb, 13.0, places=1)

    def test_validate_connection(self):
        """Test connection validation."""
        with patch('aiohttp.ClientSession') as mock_session_class:
            mock_session = AsyncMock()
            mock_response = AsyncMock()
            mock_response.status = 200

            mock_session.get.return_value.__aenter__.return_value = mock_response
            mock_session_class.return_value.__aenter__.return_value = mock_session

            is_connected = self.provider.validate_connection()

            self.assertTrue(is_connected)

    def test_get_available_models_cached(self):
        """Test getting available models uses cache."""
        with patch('aiohttp.ClientSession') as mock_session_class:
            mock_session = AsyncMock()
            mock_response = AsyncMock()
            mock_response.status = 200
            mock_response.json = AsyncMock(
                return_value={"data": [{
                    "id": "mlx-community/test-model",
                    "object": "model"
                }]})

            mock_session.get.return_value.__aenter__.return_value = mock_response
            mock_session_class.return_value.__aenter__.return_value = mock_session

            # First call
            models1 = self.provider.list_models()
            # Second call should use cache
            models2 = self.provider.list_models()

            self.assertEqual(models1, models2)
            # Should only make one API call due to caching
            mock_session.get.assert_called_once()


if __name__ == '__main__':
    unittest.main()
