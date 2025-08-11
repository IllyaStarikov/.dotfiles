"""
Tests for huggingface.py provider module.
"""

import unittest
from unittest.mock import patch, MagicMock, AsyncMock
import aiohttp

from cortex.providers.huggingface import HuggingFaceProvider
from cortex.providers import ModelInfo, ModelCapability


class TestHuggingFaceProvider(unittest.TestCase):
    """Test HuggingFace Provider."""

    def setUp(self):
        """Set up test fixtures."""
        self.provider = HuggingFaceProvider()

    def test_initialization(self):
        """Test HuggingFace provider initialization."""
        self.assertEqual(self.provider.name, "huggingface")
        self.assertEqual(self.provider.api_url, "https://huggingface.co/api")
        self.assertFalse(self.provider.supports_download)
        self.assertFalse(self.provider.requires_api_key)

    @patch('aiohttp.ClientSession')
    def test_list_models_success(self, mock_session_class):
        """Test listing HuggingFace models successfully."""
        mock_session = AsyncMock()
        mock_response = AsyncMock()
        mock_response.status = 200
        mock_response.json = AsyncMock(return_value=[
            {
                "modelId": "meta-llama/Llama-2-7b-chat-hf",
                "downloads": 50000,
                "likes": 1000,
                "tags": ["text-generation", "conversational"],
                "private": False
            },
            {
                "modelId": "codellama/CodeLlama-13b-Python-hf",
                "downloads": 30000,
                "likes": 500,
                "tags": ["text-generation", "code"],
                "private": False
            }
        ])

        mock_session.get.return_value.__aenter__.return_value = mock_response
        mock_session_class.return_value.__aenter__.return_value = mock_session

        models = self.provider.list_models()

        self.assertEqual(len(models), 2)
        self.assertEqual(models[0].id, "meta-llama/Llama-2-7b-chat-hf")
        self.assertEqual(models[0].provider, "huggingface")
        self.assertTrue(models[0].open_source)

        # Check capabilities
        self.assertIn(ModelCapability.CHAT, models[0].capabilities)
        self.assertIn(ModelCapability.CODE, models[1].capabilities)

    @patch('aiohttp.ClientSession')
    def test_list_models_api_error(self, mock_session_class):
        """Test listing models when API fails."""
        mock_session = AsyncMock()
        mock_session.get.side_effect = aiohttp.ClientError("API error")
        mock_session_class.return_value.__aenter__.return_value = mock_session

        models = self.provider.list_models()

        self.assertEqual(models, [])

    def test_chat_not_supported(self):
        """Test that chat is not directly supported."""
        response = self.provider.chat("Test prompt", model="some-model")

        self.assertIn("not supported", response.lower())

    def test_download_not_supported(self):
        """Test that download is not directly supported."""
        result = self.provider.download_model("some-model")

        self.assertFalse(result)

    def test_parse_model_size(self):
        """Test parsing model size from ID."""
        # Test various model ID formats
        test_cases = [
            ("org/model-7b", 7.0),
            ("org/model-13b-instruct", 13.0),
            ("org/model-70b-chat", 70.0),
            ("org/model-1.5b", 1.5),
            ("org/model-unknown", 1.0),  # Default
        ]

        for model_id, expected_size in test_cases:
            model_info = self.provider._parse_model_info({
                "modelId": model_id,
                "downloads": 1000,
                "likes": 10,
                "tags": [],
                "private": False
            })
            self.assertAlmostEqual(model_info.size_gb, expected_size, places=1)


if __name__ == '__main__':
    unittest.main()