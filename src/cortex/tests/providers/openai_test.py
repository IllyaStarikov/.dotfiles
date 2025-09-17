"""
Tests for openai.py provider module.
"""

import os
import unittest
from unittest.mock import MagicMock
from unittest.mock import patch

from cortex.providers import ModelCapability
from cortex.providers import ModelInfo
from cortex.providers.openai import OpenAIProvider


class TestOpenAIProvider(unittest.TestCase):
    """Test OpenAI Provider."""

    def setUp(self):
        """Set up test fixtures."""
        os.environ["OPENAI_API_KEY"] = "test-key"
        self.provider = OpenAIProvider()

    def tearDown(self):
        """Clean up."""
        if "OPENAI_API_KEY" in os.environ:
            del os.environ["OPENAI_API_KEY"]

    def test_initialization(self):
        """Test OpenAI provider initialization."""
        self.assertEqual(self.provider.name, "openai")
        self.assertFalse(self.provider.supports_download)
        self.assertTrue(self.provider.requires_api_key)

    def test_list_models(self):
        """Test listing OpenAI models."""
        models = self.provider.list_models()

        self.assertGreater(len(models), 0)

        model_ids = [m.id for m in models]
        self.assertIn("gpt-4-turbo-preview", model_ids)
        self.assertIn("gpt-3.5-turbo", model_ids)

        for model in models:
            self.assertEqual(model.provider, "openai")
            self.assertTrue(model.online)
            self.assertFalse(model.open_source)

    @patch('openai.OpenAI')
    def test_chat_success(self, mock_openai_class):
        """Test chat with OpenAI model."""
        mock_client = MagicMock()
        mock_openai_class.return_value = mock_client

        mock_response = MagicMock()
        mock_response.choices = [MagicMock(message=MagicMock(content="GPT response"))]
        mock_client.chat.completions.create.return_value = mock_response

        response = self.provider.chat("Test prompt", model="gpt-4")

        self.assertEqual(response, "GPT response")

    def test_chat_no_api_key(self):
        """Test chat without API key."""
        del os.environ["OPENAI_API_KEY"]
        provider = OpenAIProvider()

        response = provider.chat("Test prompt", model="gpt-4")

        self.assertIn("API key not found", response)


if __name__ == '__main__':
    unittest.main()
