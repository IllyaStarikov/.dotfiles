"""
Tests for google.py provider module.
"""

import unittest
from unittest.mock import patch, MagicMock
import os

from cortex.providers.google import GoogleProvider
from cortex.providers import ModelInfo, ModelCapability


class TestGoogleProvider(unittest.TestCase):
    """Test Google Provider."""

    def setUp(self):
        """Set up test fixtures."""
        os.environ["GEMINI_API_KEY"] = "test-key"
        self.provider = GoogleProvider()

    def tearDown(self):
        """Clean up."""
        for key in ["GEMINI_API_KEY", "GOOGLE_API_KEY"]:
            if key in os.environ:
                del os.environ[key]

    def test_initialization(self):
        """Test Google provider initialization."""
        self.assertEqual(self.provider.name, "gemini")
        self.assertFalse(self.provider.supports_download)
        self.assertTrue(self.provider.requires_api_key)

    def test_list_models(self):
        """Test listing Google models."""
        models = self.provider.list_models()

        self.assertGreater(len(models), 0)

        model_ids = [m.id for m in models]
        self.assertIn("gemini-1.5-pro", model_ids)
        self.assertIn("gemini-1.5-flash", model_ids)

        for model in models:
            self.assertEqual(model.provider, "gemini")
            self.assertTrue(model.online)

    @patch('google.generativeai.GenerativeModel')
    def test_chat_success(self, mock_model_class):
        """Test chat with Gemini model."""
        mock_model = MagicMock()
        mock_model_class.return_value = mock_model

        mock_response = MagicMock()
        mock_response.text = "Gemini response"
        mock_model.generate_content.return_value = mock_response

        response = self.provider.chat("Test prompt", model="gemini-1.5-pro")

        self.assertEqual(response, "Gemini response")

    def test_chat_no_api_key(self):
        """Test chat without API key."""
        del os.environ["GEMINI_API_KEY"]
        provider = GoogleProvider()

        response = provider.chat("Test prompt", model="gemini-1.5-pro")

        self.assertIn("API key not found", response)


if __name__ == '__main__':
    unittest.main()