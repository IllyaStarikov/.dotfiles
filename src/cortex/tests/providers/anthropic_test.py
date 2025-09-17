"""
Tests for anthropic.py provider module.
"""

import os
import unittest
from unittest.mock import MagicMock
from unittest.mock import patch

from cortex.providers import ModelCapability
from cortex.providers import ModelInfo
from cortex.providers.anthropic import AnthropicProvider


class TestAnthropicProvider(unittest.TestCase):
    """Test Anthropic Provider."""

    def setUp(self):
        """Set up test fixtures."""
        # Set mock API key
        os.environ["ANTHROPIC_API_KEY"] = "test-key"
        self.provider = AnthropicProvider()

    def tearDown(self):
        """Clean up."""
        if "ANTHROPIC_API_KEY" in os.environ:
            del os.environ["ANTHROPIC_API_KEY"]

    def test_initialization(self):
        """Test Anthropic provider initialization."""
        self.assertEqual(self.provider.name, "claude")
        self.assertFalse(self.provider.supports_download)
        self.assertTrue(self.provider.requires_api_key)

    def test_list_models(self):
        """Test listing Anthropic models."""
        models = self.provider.list_models()

        self.assertGreater(len(models), 0)

        # Check for known models
        model_ids = [m.id for m in models]
        self.assertIn("claude-3-5-sonnet-20241022", model_ids)
        self.assertIn("claude-3-opus-20240229", model_ids)

        # Check model properties
        for model in models:
            self.assertEqual(model.provider, "claude")
            self.assertTrue(model.online)
            self.assertFalse(model.open_source)
            self.assertIn(ModelCapability.CHAT, model.capabilities)

    @patch('anthropic.Anthropic')
    def test_chat_success(self, mock_anthropic_class):
        """Test chat with Claude model."""
        mock_client = MagicMock()
        mock_anthropic_class.return_value = mock_client

        mock_response = MagicMock()
        mock_response.content = [MagicMock(text="Claude response")]
        mock_client.messages.create.return_value = mock_response

        response = self.provider.chat("Test prompt", model="claude-3-opus")

        self.assertEqual(response, "Claude response")
        mock_client.messages.create.assert_called_once()

    def test_chat_no_api_key(self):
        """Test chat without API key."""
        del os.environ["ANTHROPIC_API_KEY"]
        provider = AnthropicProvider()

        response = provider.chat("Test prompt", model="claude-3-opus")

        self.assertIn("API key not found", response)

    def test_download_not_supported(self):
        """Test that download is not supported."""
        result = self.provider.download_model("claude-3-opus")

        self.assertFalse(result)


if __name__ == '__main__':
    unittest.main()
