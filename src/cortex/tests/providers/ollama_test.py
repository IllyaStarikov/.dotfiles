"""
Tests for ollama.py provider module.
"""

import unittest
from unittest.mock import patch, MagicMock, AsyncMock
import aiohttp

from cortex.providers.ollama import OllamaProvider
from cortex.providers import ModelInfo, ModelCapability


class TestOllamaProvider(unittest.TestCase):
    """Test Ollama Provider."""

    def setUp(self):
        """Set up test fixtures."""
        self.provider = OllamaProvider()

    def test_initialization(self):
        """Test Ollama provider initialization."""
        self.assertEqual(self.provider.name, "ollama")
        self.assertEqual(self.provider.base_url, "http://localhost:11434")
        self.assertTrue(self.provider.supports_download)
        self.assertFalse(self.provider.requires_api_key)

    @patch('aiohttp.ClientSession')
    def test_list_models_success(self, mock_session_class):
        """Test listing Ollama models successfully."""
        mock_session = AsyncMock()
        mock_response = AsyncMock()
        mock_response.status = 200
        mock_response.json = AsyncMock(return_value={
            "models": [
                {
                    "name": "llama2:latest",
                    "size": 3825819519,  # ~3.8GB
                    "modified_at": "2024-01-01T12:00:00Z"
                },
                {
                    "name": "codellama:13b",
                    "size": 13958643712,  # ~14GB
                    "modified_at": "2024-01-01T12:00:00Z"
                }
            ]
        })

        mock_session.get.return_value.__aenter__.return_value = mock_response
        mock_session_class.return_value.__aenter__.return_value = mock_session

        models = self.provider.list_models()

        self.assertEqual(len(models), 2)
        self.assertEqual(models[0].id, "llama2:latest")
        self.assertAlmostEqual(models[0].size_gb, 3.8, places=1)
        self.assertEqual(models[0].provider, "ollama")

    @patch('subprocess.run')
    def test_download_model_success(self, mock_run):
        """Test downloading Ollama model successfully."""
        mock_run.return_value = MagicMock(returncode=0)

        result = self.provider.download_model("llama2")

        self.assertTrue(result)
        mock_run.assert_called_once_with(
            ["ollama", "pull", "llama2"],
            capture_output=True,
            text=True
        )

    @patch('aiohttp.ClientSession')
    def test_chat_success(self, mock_session_class):
        """Test chat with Ollama model."""
        mock_session = AsyncMock()
        mock_response = AsyncMock()
        mock_response.status = 200

        # Simulate streaming response
        mock_response.content.iter_any = AsyncMock()
        mock_response.content.iter_any.return_value = [
            b'{"message": {"content": "Hello "}}',
            b'{"message": {"content": "world"}}',
            b'{"done": true}'
        ]

        mock_session.post.return_value.__aenter__.return_value = mock_response
        mock_session_class.return_value.__aenter__.return_value = mock_session

        response = self.provider.chat("Test prompt", model="llama2")

        self.assertEqual(response, "Hello world")


if __name__ == '__main__':
    unittest.main()